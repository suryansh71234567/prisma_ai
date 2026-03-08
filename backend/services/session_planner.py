"""Prisma AI — Session Planner Service.

Generates a SessionPlan at the start of each tutoring session.
Called ONCE per session — not on every message.

Flow: Neo4j + Postgres context → LLM prompt → parse → Redis → return.
"""

import json
import logging
import re

from semantic_kernel import Kernel
from semantic_kernel.contents import ChatHistory
from semantic_kernel.connectors.ai.prompt_execution_settings import PromptExecutionSettings

from db import neo4j_service, postgres_service, redis_service
from models.session import SessionPlan

logger = logging.getLogger(__name__)

PLANNER_SYSTEM_PROMPT = """\
You are a session planner for a JEE tutoring system.
Generate a focused 25-minute study session plan.
Respond ONLY with valid JSON matching the schema exactly.
No explanation, no markdown, no preamble."""

PLANNER_USER_TEMPLATE = """\
Student's weak concepts (mastery < 0.6):
{weak_concepts}

Available analogy bridges (concepts student knows well that map to weak concepts):
{analogy_bridges}

Recent session summaries:
{recent_sessions_formatted}

Sessions completed today: {session_count_today}

Rules:
- max_exchanges is always 20
- The session is 25 minutes long. Allocate time across phases:
  INTRO 2min, DEFINITION 4min, EXAMPLES 5min,
  LOGICAL_QUESTIONS 5min, PROBLEM 7min, WRAP_UP 2min.
  Adjust phase time budgets based on student's weak areas —
  if student has PREREQUISITE_GAP errors, give more time
  to DEFINITION and EXAMPLES. If SURFACE_KNOWLEDGE errors,
  give more time to PROBLEM phase.
- Pick ONE primary concept to teach
- Choose revision_concepts that embed naturally into questions about the primary concept
- If sessions_today >= 6, set difficulty_baseline <= 0.5 and choose a concept student almost knows (mastery 0.4-0.6)
- error_focus must come from the recent session summaries
- session_goal must be one sentence, specific, actionable
- forbidden_concepts: concepts with mastery < 0.2 (too weak to touch cold)

Return this exact JSON schema:
{{
  "target_concepts": ["primary_concept_id"],
  "question_sequence": [
    {{
      "primary_concept": "concept_id",
      "revision_concepts": ["concept_id_1", "concept_id_2"],
      "error_target": "one of: PREREQUISITE_GAP | CONFUSION_ERROR | SPECIAL_CASE_FIXATION | ANALOGICAL_TRANSFER_FAILURE | COORDINATION_FAILURE | DISCRIMINATION_FAILURE | PROBLEM_TYPE_UNFAMILIARITY | SURFACE_KNOWLEDGE",
      "difficulty": 0.0,
      "question_type": "numerical | mcq | proof"
    }}
  ],
  "difficulty_baseline": 0.0,
  "error_focus": ["error_type"],
  "forbidden_concepts": ["concept_id"],
  "session_goal": "one sentence",
  "max_exchanges": 20,
  "decay_risk_concepts": ["concept_id"],
  "adaptation_rules": {{
    "consecutive_wrong_3": "fetch_prerequisite",
    "consecutive_correct_5": "increase_difficulty"
  }}
}}"""


def _extract_json(text: str) -> dict:
    """Defensively extract a JSON object from LLM output.

    Handles markdown fences, surrounding prose, etc.

    Raises:
        ValueError: If no valid JSON object can be found.
    """
    # Strip markdown code fences if present
    cleaned = re.sub(r"```(?:json)?\s*", "", text)
    cleaned = re.sub(r"```", "", cleaned).strip()

    # Try direct parse first
    try:
        return json.loads(cleaned)
    except json.JSONDecodeError:
        pass

    # Try to find a JSON object with regex
    match = re.search(r"\{[\s\S]*\}", cleaned)
    if match:
        try:
            return json.loads(match.group())
        except json.JSONDecodeError:
            pass

    raise ValueError(
        f"Could not extract valid JSON from LLM response. "
        f"Raw output (first 500 chars): {text[:500]}"
    )


def _format_recent_sessions(records: list[dict]) -> str:
    """Format recent session records for the prompt."""
    if not records:
        return "No previous sessions for this chapter."

    lines = []
    for i, r in enumerate(records, 1):
        date_str = r["created_at"].isoformat() if r.get("created_at") else "unknown"
        lines.append(
            f"Session {i} ({date_str}):\n"
            f"  Summary: {r['planner_summary']}\n"
            f"  Completion: {r['plan_completion_rate']:.0%}\n"
            f"  Off-plan concepts: {r.get('off_plan_concepts', [])}"
        )
    return "\n".join(lines)


class SessionPlanner:
    """Generates a SessionPlan by feeding KG + Postgres context to the LLM."""

    def __init__(self, kernel: Kernel, neo4j_driver, pool, redis):
        self.kernel = kernel
        self.neo4j_driver = neo4j_driver
        self.pool = pool
        self.redis = redis

    def _sanitize_plan_dict(self, parsed: dict) -> dict:
        baseline = parsed.get("difficulty_baseline")
        if baseline is None or baseline == 0.0:
            parsed["difficulty_baseline"] = 0.4

        if not parsed.get("session_goal"):
            tc = parsed.get("target_concepts", ["this concept"])
            concept = tc[0] if tc else "this concept"
            parsed["session_goal"] = f"Study {concept}"

        baseline = parsed.get("difficulty_baseline", 0.4)

        for q in parsed.get("question_sequence", []):
            if not q.get("error_target"):
                q["error_target"] = "PREREQUISITE_GAP"
            
            diff = q.get("difficulty")
            if diff is None or diff == 0.0:
                q["difficulty"] = baseline
                
            if not q.get("question_type"):
                q["question_type"] = "numerical"
                
        return parsed

    async def create_plan(
        self,
        student_id: str,
        session_id: str,
        chapter: str,
    ) -> SessionPlan:
        """Generate a SessionPlan for a new tutoring session.

        Steps:
            1. Gather context from Neo4j + Postgres
            2. Build prompt
            3. Call LLM
            4. Parse and validate response
            5. Write to Redis
            6. Return SessionPlan

        Raises:
            ValueError: If LLM output cannot be parsed or validated.
        """

        # ── Step 1: Gather context ────────────────────────────────────
        planner_context = await neo4j_service.get_planner_context(
            self.neo4j_driver, student_id, chapter
        )

        recent_sessions = await postgres_service.get_recent_session_records(
            self.pool, student_id, chapter, limit=3
        )

        session_count_today = await postgres_service.get_session_count_today(
            self.pool, student_id
        )

        # ── Step 2: Build prompt ──────────────────────────────────────
        user_prompt = PLANNER_USER_TEMPLATE.format(
            weak_concepts=json.dumps(planner_context["weak_concepts"], default=str),
            analogy_bridges=json.dumps(planner_context["analogy_bridges"], default=str),
            recent_sessions_formatted=_format_recent_sessions(recent_sessions),
            session_count_today=session_count_today,
        )

        chat_history = ChatHistory()
        chat_history.add_system_message(PLANNER_SYSTEM_PROMPT)
        chat_history.add_user_message(user_prompt)

        # ── Step 3: Call LLM ──────────────────────────────────────────
        execution_settings = PromptExecutionSettings(
            service_id="default",
        )

        chat_service = self.kernel.get_service("default")
        result = await chat_service.get_chat_message_contents(
            chat_history=chat_history,
            settings=execution_settings,
            kernel=self.kernel,
        )

        raw_response = str(result[0])
        logger.debug("Planner LLM raw response: %s", raw_response[:500])

        # ── Step 4: Parse and validate ────────────────────────────────
        try:
            parsed = _extract_json(raw_response)
        except ValueError:
            logger.error("Planner LLM returned unparseable output: %s", raw_response)
            raise

        # Inject session_id — LLM doesn't know it
        parsed["session_id"] = session_id

        try:
            sanitized = self._sanitize_plan_dict(parsed)
            plan = SessionPlan.model_validate(sanitized)
        except Exception as e:
            logger.error(
                "Planner output failed SessionPlan validation: %s\nParsed: %s",
                e,
                json.dumps(parsed, indent=2, default=str),
            )
            raise ValueError(
                f"LLM output failed SessionPlan validation: {e}"
            ) from e

        # ── Step 5: Write to Redis ────────────────────────────────────
        await redis_service.save_session_plan(self.redis, session_id, plan)

        return plan
