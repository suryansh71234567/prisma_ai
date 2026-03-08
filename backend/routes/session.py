"""Prisma AI — Session routes.

Routes for starting a session, exchanging messages, and ending a session.
Thin wrappers around the planner, tutor, and summarizer services.
"""

import uuid
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel

from auth.jwt import get_current_student
from db import postgres_service, redis_service
from models.events import TurnSignal

router = APIRouter(prefix="/api/session", tags=["session"])


class StartSessionRequest(BaseModel):
    chapter: str


class StartSessionResponse(BaseModel):
    session_id: str
    session_goal: str
    primary_concept: str
    difficulty: float


class MessageRequest(BaseModel):
    session_id: str
    message: str
    turn_signal: TurnSignal


class MessageResponse(BaseModel):
    response: str
    session_id: str


class EndSessionRequest(BaseModel):
    session_id: str
    exchange_events: list[dict] = []


class EndSessionResponse(BaseModel):
    summary: str
    plan_completion_rate: float


@router.post("/start", response_model=StartSessionResponse)
async def start_session(
    request: Request,
    body: StartSessionRequest,
    student_id: str = Depends(get_current_student),
):
    """Start a new tutoring session for a specific chapter."""
    planner = request.app.state.planner
    redis = request.app.state.redis
    
    session_id = str(uuid.uuid4())

    plan = await planner.create_plan(student_id, session_id, body.chapter)

    # Save chapter to Redis for retrieval in /end
    await redis.set(f"session:{session_id}:chapter", body.chapter, ex=7200)

    return StartSessionResponse(
        session_id=session_id,
        session_goal=plan.session_goal,
        primary_concept=plan.target_concepts[0] if plan.target_concepts else "",
        difficulty=plan.difficulty_baseline,
    )


@router.post("/message", response_model=MessageResponse)
async def send_message(
    request: Request,
    body: MessageRequest,
    student_id: str = Depends(get_current_student),
):
    """Process a single student message during an active session."""
    tutor = request.app.state.tutor

    response_text, _event = await tutor.process_message(
        session_id=body.session_id,
        student_id=student_id,
        message=body.message,
        turn_signal=body.turn_signal,
    )

    return MessageResponse(
        response=response_text,
        session_id=body.session_id,
    )


@router.post("/end", response_model=EndSessionResponse)
async def end_session(
    request: Request,
    body: EndSessionRequest,
    student_id: str = Depends(get_current_student),
):
    """End a session and generate a permanent record."""
    summarizer = request.app.state.summarizer
    pool = request.app.state.pool
    redis = request.app.state.redis

    # Load plan from Redis
    plan = await redis_service.get_session_plan(redis, body.session_id)
    if plan is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found",
        )

    # Load chapter from Redis, fallback to plan
    raw_chapter = await redis.get(f"session:{body.session_id}:chapter")
    if raw_chapter:
        chapter = raw_chapter.decode() if isinstance(raw_chapter, bytes) else raw_chapter
    else:
        chapter = plan.target_concepts[0] if plan.target_concepts else "unknown"

    # Generate summary
    result = await summarizer.run_end_of_session(
        session_id=body.session_id,
        student_id=student_id,
        chapter=chapter,
        plan=plan,
        exchange_events=body.exchange_events,
    )

    # Persist session record
    record_id = str(uuid.uuid4())
    await postgres_service.save_session_record(
        pool,
        {
            "id": record_id,
            "student_id": student_id,
            "chapter": chapter,
            "session_number_today": result["session_number_today"],
            "plan_completion_rate": result["plan_completion_rate"],
            "off_plan_concepts": result["off_plan_concepts"],
            "planner_summary": result["planner_summary"],
            "interaction_log": result["interaction_log"],
        },
    )

    return EndSessionResponse(
        summary=result["student_facing_summary"],
        plan_completion_rate=result["plan_completion_rate"],
    )
