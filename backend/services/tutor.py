"""Prisma AI — Tutor Service.

Orchestrates Semantic Kernel, three plugins (KnowledgeGraph, Notes,
StudentProfile), and Redis-backed conversation history to power
the Socratic tutoring loop.

Called by the route layer on every student message.
No database writes. No direct Neo4j/Postgres calls — only through plugins.
"""

import time

from semantic_kernel import Kernel
from semantic_kernel.contents import ChatHistory, ChatMessageContent, AuthorRole
from semantic_kernel.connectors.ai.open_ai import OpenAIChatPromptExecutionSettings

from db import redis_service
from models.events import ExchangeEvent, TurnSignal
from models.session import SessionPlan
from plugins.kg_plugin import KnowledgeGraphPlugin
from plugins.notes_plugin import NotesPlugin
from plugins.student_profile_plugin import StudentProfilePlugin


class TutorService:
    """Orchestrates the Socratic tutoring loop via Semantic Kernel."""

    def __init__(self, kernel: Kernel, neo4j_driver, pool, redis, vector_store):
        """Register all three plugins on the kernel and store dependencies."""
        self.kernel = kernel
        self.redis = redis

        self.kernel.add_plugin(
            KnowledgeGraphPlugin(neo4j_driver),
            plugin_name="knowledge_graph",
        )
        self.kernel.add_plugin(
            NotesPlugin(vector_store, pool),
            plugin_name="notes",
        )
        self.kernel.add_plugin(
            StudentProfilePlugin(pool, neo4j_driver),
            plugin_name="student_profile",
        )

    # ------------------------------------------------------------------
    # Core tutoring loop
    # ------------------------------------------------------------------

    async def process_message(
        self,
        session_id: str,
        student_id: str,
        message: str,
        turn_signal: TurnSignal,
    ) -> tuple[str, ExchangeEvent]:
        """Process one student message and return (response_text, event).

        The route layer stores the ExchangeEvent — this service just
        produces it.

        Raises:
            ValueError: If session plan not found in Redis.
        """

        # ── Step 1: Load state from Redis ─────────────────────────────
        plan = await redis_service.get_session_plan(self.redis, session_id)
        if plan is None:
            raise ValueError(
                f"No session plan found for session {session_id}. "
                f"Call /api/session/start first."
            )

        history = await redis_service.get_conversation_history(
            self.redis, session_id
        )

        # ── Step 2: Compute adaptation context ────────────────────────
        adaptation_note = ""

        if (
            "consecutive_wrong_3" in plan.adaptation_rules
            and turn_signal.consecutive_wrong >= 3
        ):
            adaptation_note = (
                "ADAPTATION TRIGGERED: Student has answered incorrectly 3 times "
                "in a row. Before your next question, call "
                "knowledge_graph.find_prerequisite_gaps with the current concept "
                "to identify the root cause. Address the gap explicitly."
            )
        elif (
            "consecutive_correct_5" in plan.adaptation_rules
            and turn_signal.consecutive_correct >= 5
        ):
            adaptation_note = (
                "ADAPTATION TRIGGERED: Student is performing very well. "
                f"Increase difficulty for the next question above "
                f"{plan.difficulty_baseline + 0.15:.2f}."
            )

        # ── Step 3: Build system prompt ───────────────────────────────
        primary_concept = (
            plan.target_concepts[0] if plan.target_concepts else "general"
        )
        error_focus_str = (
            ", ".join(e.value if hasattr(e, "value") else str(e) for e in plan.error_focus)
            if plan.error_focus
            else "none specified"
        )
        forbidden_str = ", ".join(plan.forbidden_concepts) if plan.forbidden_concepts else "none"

        system_prompt = f"""You are a Socratic tutor for JEE Physics. Your method:
- Ask questions that make the student THINK. Do not give answers directly.
- When student is wrong: ask what they think is wrong, give a hint toward the reasoning gap, not the answer.
- When student asks for explanation: retrieve from notes plugin first, then explain concisely, then immediately ask a follow-up question.
- When student asks for a practice question: use notes.search_questions.

SESSION CONTEXT:
Goal: {plan.session_goal}
Primary concept: {primary_concept}
Difficulty target: {plan.difficulty_baseline}/1.0
Error types to probe: {error_focus_str}
Concepts to avoid (student not ready): {forbidden_str}

TOOL USAGE RULES:
- Call knowledge_graph.find_prerequisite_gaps when student fails due to missing foundation
- Call knowledge_graph.find_confusion_pair when student applies the right method to the wrong concept
- Call knowledge_graph.find_analogy_bridge when student has zero mastery on a concept but you know they understand an analogous one
- Call notes.search_questions when you need a practice problem
- Call notes.search_notes when student asks for theory explanation
- Do NOT call student_profile plugin during conversation — it was already used at session start

{adaptation_note}"""

        # ── Step 4: Build chat history for SK ─────────────────────────
        messages = []
        for msg in history:
            role = (
                AuthorRole.USER if msg["role"] == "user" else AuthorRole.ASSISTANT
            )
            messages.append(
                ChatMessageContent(role=role, content=msg["content"])
            )
        messages.append(
            ChatMessageContent(role=AuthorRole.USER, content=message)
        )

        # ── Step 5: Invoke kernel ─────────────────────────────────────
        execution_settings = OpenAIChatPromptExecutionSettings(
            service_id="default",
            max_tokens=1024,
            temperature=0.7,
        )

        chat_service = self.kernel.get_service("default")

        response = await chat_service.get_chat_message_contents(
            chat_history=ChatHistory(messages=messages),
            settings=execution_settings,
            kernel=self.kernel,
            system_message=system_prompt,
        )

        response_text = str(response[0])

        # ── Step 6: Update Redis history ──────────────────────────────
        await redis_service.append_to_history(
            self.redis, session_id, "user", message
        )
        await redis_service.append_to_history(
            self.redis, session_id, "assistant", response_text
        )

        # ── Step 7: Build ExchangeEvent and return ────────────────────
        event = ExchangeEvent(
            event_type="answer_submitted",
            timestamp_ms=int(time.time() * 1000),
            payload=message,
        )

        return response_text, event
