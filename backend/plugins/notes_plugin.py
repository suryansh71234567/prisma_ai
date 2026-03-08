"""Prisma AI — Notes Plugin for Semantic Kernel.

Gives the tutor agent access to:
1. Question bank — semantic search via VectorStore
2. Student notes — stub until Azure AI Search is ready

All return types are str (Semantic Kernel requirement).
"""

import json
from typing import Annotated

import asyncpg
from semantic_kernel.functions import kernel_function

from services.vector_store import VectorStore


class NotesPlugin:
    """Semantic Kernel plugin for question bank search and notes retrieval."""

    def __init__(self, vector_store: VectorStore, pool: asyncpg.Pool):
        self._vs = vector_store
        self._pool = pool

    # ------------------------------------------------------------------
    # Q-bank search
    # ------------------------------------------------------------------
    @kernel_function(
        description=(
            "Search the question bank for questions matching a concept and "
            "error type. Call when you need a practice question for the "
            "student. Input should describe what kind of question is needed."
        )
    )
    async def search_questions(
        self,
        query: Annotated[str, "Natural-language description of the question needed"],
        concept_id: Annotated[str, "Optional concept ID to narrow the search"] = "",
        top_k: Annotated[int, "Number of questions to return"] = 3,
    ) -> str:
        search_query = f"{concept_id} {query}".strip() if concept_id else query

        question_ids = await self._vs.search(search_query, top_k)

        if question_ids:
            rows = await self._pool.fetch(
                """
                SELECT id, question_text, difficulty, error_target,
                       question_type, solution
                FROM questions
                WHERE id = ANY($1)
                """,
                question_ids,
            )
            questions = [dict(r) for r in rows]
            return json.dumps(questions, default=str)

        # Fallback: no matches or empty index
        return json.dumps([{
            "question_text": f"No questions found in bank. "
                             f"Generate a question about: {query}",
            "difficulty": 0.5,
            "source": "generated",
        }])

    # ------------------------------------------------------------------
    # Notes search (stub)
    # ------------------------------------------------------------------
    @kernel_function(
        description=(
            "Retrieve relevant theory or explanation from the student's "
            "uploaded notes. Call when student asks for explanation of "
            "a concept."
        )
    )
    async def search_notes(
        self,
        query: Annotated[str, "The concept or topic to look up in notes"],
        student_id: Annotated[str, "The student whose notes to search"] = "",
    ) -> str:
        # STUB — embeddings not built yet
        # This will be replaced when Azure AI Search is ready
        return json.dumps({
            "source": "stub",
            "content": f"Notes retrieval not yet implemented. "
                       f"Use your knowledge to explain: {query}",
        })
