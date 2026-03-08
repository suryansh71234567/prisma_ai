"""Prisma AI — End-of-session Summarizer.

Generates a handoff summary for the session planner, computes
plan-completion metrics, and packages everything the route needs
to call save_session_record.

No database writes happen here — the route layer is responsible for that.
"""

import json
import logging
import re

from semantic_kernel import Kernel
from semantic_kernel.contents import ChatHistory, ChatMessageContent, AuthorRole
from semantic_kernel.connectors.ai.open_ai import OpenAIChatPromptExecutionSettings

from db import redis_service, postgres_service
from models.session import SessionPlan

logger = logging.getLogger(__name__)


class Summarizer:
    """Produces an end-of-session summary dict ready for persistence."""

    def __init__(self, kernel: Kernel, pool, redis):
        """Store kernel, Postgres pool, and Redis client."""
        self.kernel = kernel
        self.pool = pool
        self.redis = redis

    # ------------------------------------------------------------------
    # Public entry point
    # ------------------------------------------------------------------

    async def run_end_of_session(
        self,
        session_id: str,
        student_id: str,
        chapter: str,
        plan: SessionPlan,
        exchange_events: list[dict],
    ) -> dict:
        """Build and return the summary dict the route sends to save_session_record.

        Returned keys:
            planner_summary, student_facing_summary, off_plan_concepts,
            plan_completion_rate, session_number_today, interaction_log
        """

        # ── Step 1: Flush conversation history from Redis ─────────────
        history = await redis_service.flush_history_to_dict(
            self.redis, session_id
        )
        if not history:
            history = []

        # ── Step 2: Compute plan_completion_rate (rule-based) ─────────
        questions_asked = sum(
            1 for e in exchange_events
            if e.get("event_type") == "answer_submitted"
        )
        plan_completion_rate = min(
            questions_asked / plan.max_exchanges, 1.0
        ) if plan.max_exchanges > 0 else 0.0

        # ── Step 3: Extract off_plan_concepts (rule-based MVP) ────────
        off_plan_concepts = (
            plan.off_plan_concepts
            if hasattr(plan, "off_plan_concepts")
            else []
        )

        # ── Step 4: Get session number today ──────────────────────────
        session_number_today = await postgres_service.get_session_count_today(
            self.pool, student_id
        )
        session_number_today += 1  # this session counts

        # ── Step 5: Generate planner_summary via LLM ─────────────────
        parsed = await self._generate_summary_llm(
            chapter=chapter,
            plan=plan,
            plan_completion_rate=plan_completion_rate,
            questions_asked=questions_asked,
            history=history,
        )

        # Merge LLM-detected off-plan concepts with rule-based ones
        llm_off_plan = parsed.get("off_plan_concepts", [])
        if llm_off_plan:
            merged = list(dict.fromkeys(off_plan_concepts + llm_off_plan))
            off_plan_concepts = merged

        # ── Step 6: Return result dict ────────────────────────────────
        return {
            "planner_summary": parsed["planner_summary"],
            "student_facing_summary": parsed["student_facing_summary"],
            "off_plan_concepts": off_plan_concepts,
            "plan_completion_rate": plan_completion_rate,
            "session_number_today": session_number_today,
            "interaction_log": exchange_events,
        }

    # ------------------------------------------------------------------
    # Private — LLM summary generation
    # ------------------------------------------------------------------

    async def _generate_summary_llm(
        self,
        *,
        chapter: str,
        plan: SessionPlan,
        plan_completion_rate: float,
        questions_asked: int,
        history: list[dict],
    ) -> dict:
        """Call the LLM to produce the planner handoff summary.

        Returns a parsed dict with keys:
            planner_summary, off_plan_concepts, student_facing_summary
        Falls back to a safe default if parsing fails.
        """

        # Format conversation transcript
        conversation_text = "\n".join(
            f"{msg['role'].upper()}: {msg['content']}"
            for msg in history[-20:]  # last 20 messages max
        )

        primary_concept = (
            plan.target_concepts[0] if plan.target_concepts else "unknown"
        )

        system_prompt = (
            "You are analyzing a completed tutoring session to generate a "
            "handoff summary for the next session's planner.\n"
            "Respond ONLY with valid JSON. No markdown. No explanation."
        )

        user_prompt = f"""Session details:
- Chapter: {chapter}
- Planned primary concept: {primary_concept}
- Session goal: {plan.session_goal}
- Plan completion rate: {plan_completion_rate:.0%}
- Questions asked: {questions_asked} of {plan.max_exchanges} planned

Conversation transcript:
{conversation_text}

Generate a JSON object with exactly these fields:
{{
  "planner_summary": "2-3 sentence paragraph covering: what was taught, \
what the student mastered, what they failed at and WHY (error type), \
what was discussed off-plan. Be specific about concept names and \
error types (use: PREREQUISITE_GAP, CONFUSION_ERROR, \
SPECIAL_CASE_FIXATION, ANALOGICAL_TRANSFER_FAILURE, \
COORDINATION_FAILURE, DISCRIMINATION_FAILURE, \
PROBLEM_TYPE_UNFAMILIARITY, SURFACE_KNOWLEDGE).",
  "off_plan_concepts": ["list of concept_ids mentioned off-plan, \
empty array if none"],
  "student_facing_summary": "1-2 encouraging sentences for the student \
about what they accomplished and one specific thing to focus on next."
}}"""

        # ── Invoke LLM ───────────────────────────────────────────────
        try:
            chat_service = self.kernel.get_service("default")
            response = await chat_service.get_chat_message_contents(
                chat_history=ChatHistory(
                    messages=[
                        ChatMessageContent(
                            role=AuthorRole.SYSTEM, content=system_prompt
                        ),
                        ChatMessageContent(
                            role=AuthorRole.USER, content=user_prompt
                        ),
                    ]
                ),
                settings=OpenAIChatPromptExecutionSettings(
                    service_id="default",
                    max_tokens=512,
                    temperature=0.3,  # low temperature for consistent structure
                ),
            )

            raw = str(response[0])
            return self._parse_llm_response(raw, chapter, plan_completion_rate)

        except Exception:
            logger.exception("LLM call failed during summary generation")
            return self._fallback_summary(chapter, plan_completion_rate)

    # ------------------------------------------------------------------
    # Private — Defensive JSON parsing
    # ------------------------------------------------------------------

    @staticmethod
    def _parse_llm_response(
        raw: str,
        chapter: str,
        plan_completion_rate: float,
    ) -> dict:
        """Parse the LLM's raw text into a dict, with fallback on failure."""

        # Strip markdown fences if present
        cleaned = raw.strip()
        cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
        cleaned = re.sub(r"\s*```$", "", cleaned)

        # Try to extract JSON object via regex
        match = re.search(r"\{.*\}", cleaned, re.DOTALL)
        if match:
            try:
                parsed = json.loads(match.group())

                # Validate expected keys exist
                required_keys = {
                    "planner_summary",
                    "off_plan_concepts",
                    "student_facing_summary",
                }
                if required_keys.issubset(parsed.keys()):
                    return parsed

                logger.warning(
                    "LLM response missing keys: %s",
                    required_keys - parsed.keys(),
                )
            except json.JSONDecodeError:
                logger.warning("JSON decode failed on LLM response: %s", raw)

        logger.warning("Could not parse LLM summary response: %s", raw)
        return Summarizer._fallback_summary(chapter, plan_completion_rate)

    @staticmethod
    def _fallback_summary(chapter: str, plan_completion_rate: float) -> dict:
        """Safe fallback when LLM parsing fails."""
        return {
            "planner_summary": (
                f"Session on {chapter}. "
                f"Completion rate: {plan_completion_rate:.0%}. "
                f"Summary generation failed — review logs."
            ),
            "off_plan_concepts": [],
            "student_facing_summary": "Good work this session!",
        }
