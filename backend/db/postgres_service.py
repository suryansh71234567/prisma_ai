"""Prisma AI — PostgreSQL query layer.

ALL SQL queries live here and nowhere else.
No business logic, no LLM calls. Every function takes a pool as its first arg.
"""

import json
from typing import List, Optional

import asyncpg


# ---------------------------------------------------------------------------
# Schema DDL — caller runs this on startup via pool.execute()
# ---------------------------------------------------------------------------
CREATE_TABLES_SQL = """\
CREATE TABLE IF NOT EXISTS students (
  id              TEXT PRIMARY KEY,
  email           TEXT UNIQUE NOT NULL,
  name            TEXT NOT NULL,
  hashed_password TEXT NOT NULL,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS session_records (
  id                    TEXT PRIMARY KEY,
  student_id            TEXT NOT NULL,
  chapter               TEXT NOT NULL,
  session_number_today  INT NOT NULL DEFAULT 1,
  plan_completion_rate  FLOAT NOT NULL DEFAULT 0.0,
  off_plan_concepts     TEXT[] DEFAULT '{}',
  planner_summary       TEXT NOT NULL,
  interaction_log       JSONB NOT NULL DEFAULT '[]',
  created_at            TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS mastery_scores (
  id            SERIAL PRIMARY KEY,
  student_id    TEXT NOT NULL,
  concept_id    TEXT NOT NULL,
  score         FLOAT NOT NULL CHECK (score >= 0 AND score <= 1),
  last_seen     TIMESTAMPTZ DEFAULT NOW(),
  attempt_count INT DEFAULT 0,
  UNIQUE(student_id, concept_id)
);

CREATE TABLE IF NOT EXISTS questions (
  id                TEXT PRIMARY KEY,
  concept_id        TEXT NOT NULL,
  revision_concepts TEXT[] DEFAULT '{}',
  error_target      TEXT NOT NULL,
  difficulty        FLOAT NOT NULL CHECK (difficulty >= 0 AND difficulty <= 1),
  question_type     TEXT NOT NULL,
  question_text     TEXT NOT NULL,
  solution          TEXT NOT NULL,
  commentary        TEXT NOT NULL,
  embedding_id      TEXT,
  created_at        TIMESTAMPTZ DEFAULT NOW()
);
"""


# ---------------------------------------------------------------------------
# 1. Create student
# ---------------------------------------------------------------------------
async def create_student(
    pool: asyncpg.Pool,
    email: str,
    name: str,
    hashed_password: str,
) -> dict:
    """Insert a new student. Returns dict with id, email, name.

    Raises:
        asyncpg.UniqueViolationError: If email already exists.
    """
    row = await pool.fetchrow(
        """
        INSERT INTO students (id, email, name, hashed_password)
        VALUES (gen_random_uuid()::text, $1, $2, $3)
        RETURNING id, email, name
        """,
        email,
        name,
        hashed_password,
    )
    return dict(row)


# ---------------------------------------------------------------------------
# 2. Get student by email
# ---------------------------------------------------------------------------
async def get_student_by_email(
    pool: asyncpg.Pool,
    email: str,
) -> Optional[dict]:
    """Return student dict (id, email, name, hashed_password) or None."""
    row = await pool.fetchrow(
        """
        SELECT id, email, name, hashed_password
        FROM students
        WHERE email = $1
        """,
        email,
    )
    return dict(row) if row else None


# ---------------------------------------------------------------------------
# 3. Get student by ID
# ---------------------------------------------------------------------------
async def get_student_by_id(
    pool: asyncpg.Pool,
    student_id: str,
) -> Optional[dict]:
    """Return student dict (id, email, name) or None."""
    row = await pool.fetchrow(
        """
        SELECT id, email, name
        FROM students
        WHERE id = $1
        """,
        student_id,
    )
    return dict(row) if row else None


# ---------------------------------------------------------------------------
# 4. Save session record
# ---------------------------------------------------------------------------
async def save_session_record(
    pool: asyncpg.Pool,
    record: dict,
) -> None:
    """Insert a session record. *record* must have the expected keys."""
    await pool.execute(
        """
        INSERT INTO session_records (
            id, student_id, chapter, session_number_today,
            plan_completion_rate, off_plan_concepts,
            planner_summary, interaction_log
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8::jsonb)
        """,
        record["id"],
        record["student_id"],
        record["chapter"],
        record["session_number_today"],
        record["plan_completion_rate"],
        record["off_plan_concepts"],
        record["planner_summary"],
        json.dumps(record["interaction_log"]),
    )


# ---------------------------------------------------------------------------
# 5. Get recent session records
# ---------------------------------------------------------------------------
async def get_recent_session_records(
    pool: asyncpg.Pool,
    student_id: str,
    chapter: str,
    limit: int = 3,
) -> List[dict]:
    """Return the most recent session records for a student + chapter."""
    rows = await pool.fetch(
        """
        SELECT id, student_id, chapter, session_number_today,
               plan_completion_rate, off_plan_concepts,
               planner_summary, interaction_log, created_at
        FROM session_records
        WHERE student_id = $1 AND chapter = $2
        ORDER BY created_at DESC
        LIMIT $3
        """,
        student_id,
        chapter,
        limit,
    )
    return [dict(r) for r in rows]


# ---------------------------------------------------------------------------
# 6. Upsert mastery score
# ---------------------------------------------------------------------------
async def upsert_mastery_score(
    pool: asyncpg.Pool,
    student_id: str,
    concept_id: str,
    score: float,
    attempt_count: int,
) -> None:
    """Insert or update a mastery score for a student–concept pair."""
    await pool.execute(
        """
        INSERT INTO mastery_scores (student_id, concept_id, score, attempt_count, last_seen)
        VALUES ($1, $2, $3, $4, NOW())
        ON CONFLICT (student_id, concept_id) DO UPDATE
        SET score = $3, attempt_count = $4, last_seen = NOW()
        """,
        student_id,
        concept_id,
        score,
        attempt_count,
    )


# ---------------------------------------------------------------------------
# 7. Get session count today
# ---------------------------------------------------------------------------
async def get_session_count_today(
    pool: asyncpg.Pool,
    student_id: str,
) -> int:
    """Return how many sessions the student has had today."""
    row = await pool.fetchrow(
        """
        SELECT COUNT(*) AS cnt
        FROM session_records
        WHERE student_id = $1
          AND created_at >= CURRENT_DATE
        """,
        student_id,
    )
    return row["cnt"]
