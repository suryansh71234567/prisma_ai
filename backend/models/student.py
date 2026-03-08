"""Prisma AI — Student-profile Pydantic models."""

from datetime import datetime

from pydantic import BaseModel, field_validator


class Student(BaseModel):
    """Core student identity record."""

    id: str
    email: str
    name: str
    created_at: datetime


class MasteryScore(BaseModel):
    """Per-concept mastery score for a student (from KT model)."""

    concept_id: str
    student_id: str
    score: float
    last_seen: datetime
    attempt_count: int = 0

    @field_validator("score")
    @classmethod
    def _score_in_range(cls, v: float) -> float:
        if not (0.0 <= v <= 1.0):
            raise ValueError(f"score must be between 0.0 and 1.0, got {v}")
        return v
