"""Prisma AI — Student Profile Plugin for Semantic Kernel.

Gives the tutor agent access to student history, mastery scores,
and session counts. Wraps postgres_service and neo4j_service queries.

All return types are str (Semantic Kernel requirement).
"""

import json
from typing import Annotated

import asyncpg
from neo4j import AsyncDriver
from semantic_kernel.functions import kernel_function

from db import neo4j_service, postgres_service


class StudentProfilePlugin:
    """Semantic Kernel plugin for student profile and history queries."""

    def __init__(self, pool: asyncpg.Pool, neo4j_driver: AsyncDriver):
        self._pool = pool
        self._driver = neo4j_driver

    # ------------------------------------------------------------------
    # Session history
    # ------------------------------------------------------------------
    @kernel_function(
        description=(
            "Get the student's recent session history and performance summary. "
            "Call at session start to understand the student's learning "
            "trajectory and what was covered recently."
        )
    )
    async def get_session_history(
        self,
        student_id: Annotated[str, "The student's unique ID"],
        chapter: Annotated[str, "The chapter to look up history for"],
    ) -> str:
        records = await postgres_service.get_recent_session_records(
            self._pool, student_id, chapter, limit=3
        )

        if not records:
            return json.dumps({
                "history": [],
                "message": "First session for this student on this chapter",
            })

        history = []
        for r in records:
            history.append({
                "session_date": r["created_at"].isoformat() if r.get("created_at") else None,
                "summary": r["planner_summary"],
                "completion_rate": r["plan_completion_rate"],
                "off_plan_concepts": r["off_plan_concepts"],
            })

        return json.dumps(history, default=str)

    # ------------------------------------------------------------------
    # Weak concepts
    # ------------------------------------------------------------------
    @kernel_function(
        description=(
            "Get student's current mastery scores and weak concepts for a "
            "chapter. Call when building session plan or when student "
            "struggles with a concept."
        )
    )
    async def get_weak_concepts(
        self,
        student_id: Annotated[str, "The student's unique ID"],
        chapter: Annotated[str, "The chapter to check mastery for"],
    ) -> str:
        result = await neo4j_service.get_student_weak_concepts(
            self._driver, student_id, chapter, threshold=0.6, limit=10
        )
        return json.dumps(result, default=str)

    # ------------------------------------------------------------------
    # Session count today
    # ------------------------------------------------------------------
    @kernel_function(
        description=(
            "Get how many sessions the student has done today. Call when "
            "deciding session difficulty — student on session 7+ should "
            "get consolidation questions, not new content."
        )
    )
    async def get_session_count_today(
        self,
        student_id: Annotated[str, "The student's unique ID"],
    ) -> str:
        count = await postgres_service.get_session_count_today(
            self._pool, student_id
        )
        recommendation = "consolidate" if count >= 6 else "normal"
        return json.dumps({
            "count": count,
            "recommendation": recommendation,
        })
