"""Prisma AI — Redis query layer.

ALL Redis operations live here and nowhere else.
No business logic. Every function takes a redis client as its first arg.

Key patterns:
  session:{session_id}:plan          → SessionPlan JSON (TTL 2h)
  session:{session_id}:history       → list of message dicts (TTL 2h)
  student:{student_id}:lstm_state    → serialized tensor bytes (no TTL)
"""

import json
from typing import List, Optional

from models.session import SessionPlan

SESSION_TTL = 7200  # 2 hours


# ---------------------------------------------------------------------------
# 1. Save session plan
# ---------------------------------------------------------------------------
async def save_session_plan(
    redis,
    session_id: str,
    plan: SessionPlan,
) -> None:
    """Serialize and store a SessionPlan with 2-hour TTL."""
    key = f"session:{session_id}:plan"
    await redis.set(key, plan.model_dump_json(), ex=SESSION_TTL)


# ---------------------------------------------------------------------------
# 2. Get session plan
# ---------------------------------------------------------------------------
async def get_session_plan(
    redis,
    session_id: str,
) -> Optional[SessionPlan]:
    """Return the SessionPlan for a session, or None if not found."""
    key = f"session:{session_id}:plan"
    raw = await redis.get(key)
    if raw is None:
        return None
    return SessionPlan.model_validate_json(raw)


# ---------------------------------------------------------------------------
# 3. Get conversation history
# ---------------------------------------------------------------------------
async def get_conversation_history(
    redis,
    session_id: str,
) -> List[dict]:
    """Return the stored conversation history list, or [] if absent."""
    key = f"session:{session_id}:history"
    raw = await redis.get(key)
    if raw is None:
        return []
    return json.loads(raw)


# ---------------------------------------------------------------------------
# 4. Append to history
# ---------------------------------------------------------------------------
async def append_to_history(
    redis,
    session_id: str,
    role: str,
    content: str,
) -> None:
    """Append a message to history, keeping only the last 12 messages."""
    key = f"session:{session_id}:history"
    raw = await redis.get(key)
    history = json.loads(raw) if raw else []
    history.append({"role": role, "content": content})
    history = history[-12:]
    await redis.set(key, json.dumps(history), ex=SESSION_TTL)


# ---------------------------------------------------------------------------
# 5. Flush history to dict
# ---------------------------------------------------------------------------
async def flush_history_to_dict(
    redis,
    session_id: str,
) -> List[dict]:
    """Return the full history list and delete the key.

    Returns [] if the key does not exist.
    """
    key = f"session:{session_id}:history"
    raw = await redis.get(key)
    if raw is None:
        return []
    await redis.delete(key)
    return json.loads(raw)


# ---------------------------------------------------------------------------
# 6. Save LSTM state
# ---------------------------------------------------------------------------
async def save_lstm_state(
    redis,
    student_id: str,
    state_bytes: bytes,
) -> None:
    """Store serialized LSTM state bytes. No TTL — permanent."""
    key = f"student:{student_id}:lstm_state"
    await redis.set(key, state_bytes)


# ---------------------------------------------------------------------------
# 7. Get LSTM state
# ---------------------------------------------------------------------------
async def get_lstm_state(
    redis,
    student_id: str,
) -> Optional[bytes]:
    """Return raw LSTM state bytes, or None if not found."""
    key = f"student:{student_id}:lstm_state"
    return await redis.get(key)
