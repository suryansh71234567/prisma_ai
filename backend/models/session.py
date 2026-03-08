"""Prisma AI — Session-related Pydantic models."""
from typing import Optional
from typing import Dict, List, Literal
from datetime import datetime
from pydantic import BaseModel, Field, field_validator

from models.errors import ErrorType


# ---------------------------------------------------------------------------
# QuestionSpec
# ---------------------------------------------------------------------------
class QuestionSpec(BaseModel):
    """Specification for a single question the tutor will pose."""

    primary_concept: str
    revision_concepts: List[str]
    error_target: ErrorType
    difficulty: float = Field(..., ge=0.0, le=1.0, description="0.0–1.0")
    question_type: Literal["numerical", "mcq", "proof"]

    @field_validator("error_target", mode="before")
    @classmethod
    def _default_error_target(cls, v):
        valid = {e.value for e in ErrorType} if hasattr(ErrorType, "__members__") else set(ErrorType.__members__.keys()) if hasattr(ErrorType, "__members__") else set()
        # Simpler check since we know ErrorType values
        val = getattr(v, "value", v)
        if not val or val not in {"PREREQUISITE_GAP", "CONFUSION_ERROR", "SPECIAL_CASE_FIXATION", "ANALOGICAL_TRANSFER_FAILURE", "COORDINATION_FAILURE", "DISCRIMINATION_FAILURE", "PROBLEM_TYPE_UNFAMILIARITY", "SURFACE_KNOWLEDGE"}:
            return "PREREQUISITE_GAP"
        return v

    @field_validator("difficulty")
    @classmethod
    def _difficulty_in_range(cls, v: float) -> float:
        if not (0.0 <= v <= 1.0):
            raise ValueError(f"difficulty must be between 0.0 and 1.0, got {v}")
        return v


# ---------------------------------------------------------------------------
# SessionPlan
# ---------------------------------------------------------------------------
class SessionPlan(BaseModel):
    """Plan the planner LLM produces before a tutoring session starts."""

    session_id: str
    target_concepts: List[str]
    question_sequence: List[QuestionSpec]
    difficulty_baseline: float = Field(..., ge=0.0, le=1.0)
    error_focus: List[ErrorType]
    forbidden_concepts: List[str]
    session_goal: str
    max_exchanges: int = 20
    total_duration_minutes: int = 25
    decay_risk_concepts: List[str]
    adaptation_rules: Dict[str, str]


# ---------------------------------------------------------------------------
# SessionRecord
# ---------------------------------------------------------------------------
class SessionRecord(BaseModel):
    session_id: str
    student_id: str
    chapter: str
    session_number_today: int = 1
    plan_completion_rate: float = 0.0   # 0.0–1.0, validated
    off_plan_concepts: List[str] = []
    planner_summary: str                # rich paragraph: what happened + why
    interaction_log: List[dict] = []    # raw turn-by-turn exchange log
    created_at: Optional[datetime] = None
    @field_validator("plan_completion_rate")
    @classmethod
    def _correct_rate_in_range(cls, v: float) -> float:
        if not (0.0 <= v <= 1.0):
            raise ValueError(f"correct_rate must be between 0.0 and 1.0, got {v}")
        return v


# ---------------------------------------------------------------------------
# Quick smoke-test (delete after verifying)
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    plan = SessionPlan(
        session_id="sess-001",
        target_concepts=["capacitors_series", "kirchhoffs_laws", "gauss_law"],
        question_sequence=[
            QuestionSpec(
                primary_concept="capacitors_series",
                revision_concepts=["ohms_law"],
                error_target=ErrorType.PREREQUISITE_GAP,
                difficulty=0.4,
                question_type="numerical",
            ),
            QuestionSpec(
                primary_concept="kirchhoffs_laws",
                revision_concepts=["capacitors_series"],
                error_target=ErrorType.COORDINATION_FAILURE,
                difficulty=0.6,
                question_type="mcq",
            ),
        ],
        difficulty_baseline=0.5,
        error_focus=[ErrorType.PREREQUISITE_GAP, ErrorType.COORDINATION_FAILURE],
        forbidden_concepts=["wave_optics"],
        session_goal="Strengthen series-capacitor and Kirchhoff's-law fundamentals.",
        max_exchanges=20,
        decay_risk_concepts=["coulombs_law"],
        adaptation_rules={"consecutive_wrong_3": "fetch_prereq"},
    )
    print(plan.model_dump_json(indent=2))
