"""Prisma AI — Real-time event and turn-signal models."""

from typing import Literal, Optional

from pydantic import BaseModel


class ExchangeEvent(BaseModel):
    """A single fine-grained event within a tutor–student exchange."""

    event_type: Literal[
        "question_displayed",
        "student_typing_started",
        "student_typing_paused",
        "hint_requested",
        "answer_submitted",
        "answer_edited",
        "answer_resubmitted",
    ]
    timestamp_ms: int
    payload: Optional[str] = None


class TurnSignal(BaseModel):
    """Aggregated behavioural signals the decision model consumes per turn."""

    response_latency_ms: int
    hint_requested: bool
    answer_changed: bool
    consecutive_wrong: int = 0
    consecutive_correct: int = 0
