"""Prisma AI — Database connection management.

Manages connections to Neo4j, PostgreSQL, and Redis.
No imports from models/ or services/ — zero circular-dependency risk.
"""

import os

import asyncpg
import redis.asyncio as aioredis
from dotenv import load_dotenv
from neo4j import AsyncGraphDatabase

load_dotenv()


# ---------------------------------------------------------------------------
# Neo4j
# ---------------------------------------------------------------------------
def get_neo4j_driver():
    """Return an async Neo4j driver."""
    uri = os.getenv("NEO4J_URI")
    user = os.getenv("NEO4J_USER")
    password = os.getenv("NEO4J_PASSWORD")
    return AsyncGraphDatabase.driver(uri, auth=(user, password))


# ---------------------------------------------------------------------------
# PostgreSQL
# ---------------------------------------------------------------------------
async def get_postgres_pool() -> asyncpg.Pool:
    """Create and return an asyncpg connection pool."""
    postgres_url = os.getenv("POSTGRES_URL")
    return await asyncpg.create_pool(postgres_url)


# ---------------------------------------------------------------------------
# Redis
# ---------------------------------------------------------------------------
async def get_redis_client() -> aioredis.Redis:
    """Return an async Redis client with decoded string responses.
    If REDIS_URL is 'memory://', uses fakeredis for local development.
    """
    redis_url = os.getenv("REDIS_URL", "memory://")
    if redis_url.startswith("memory://"):
        import fakeredis.aioredis
        return fakeredis.aioredis.FakeRedis(decode_responses=True)
    return aioredis.from_url(redis_url, decode_responses=True)


# ---------------------------------------------------------------------------
# Schema initialisation
# ---------------------------------------------------------------------------
_SCHEMA_SQL = """\
CREATE TABLE IF NOT EXISTS students (
    id              TEXT PRIMARY KEY,
    email           TEXT UNIQUE NOT NULL,
    name            TEXT NOT NULL,
    hashed_password TEXT NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT NOW()
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

CREATE TABLE IF NOT EXISTS exchange_events (
    id           SERIAL PRIMARY KEY,
    session_id   TEXT NOT NULL,
    event_type   TEXT NOT NULL,
    timestamp_ms BIGINT NOT NULL,
    payload      TEXT,
    created_at   TIMESTAMPTZ DEFAULT NOW()
);
"""


async def init_db(pool: asyncpg.Pool) -> None:
    """Run all CREATE TABLE statements inside a single transaction."""
    async with pool.acquire() as conn:
        async with conn.transaction():
            await conn.execute(_SCHEMA_SQL)


async def run_migration(pool, file_path):
    with open(file_path, 'r') as f:
        # Split by semicolon to run statements individually if needed, 
        # or run as one large block if the driver supports it.
        cypher_script = f.read()
        async with pool.acquire() as conn:
            # Note: Some drivers require splitting statements; 
            # neo4j's AsyncGraphDatabase usually handles blocks.
            await conn.execute(cypher_script)



