# scripts/integration_test.py
# Run with: python integration_test.py

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "backend"))

import asyncio
from config.llm_provider import build_kernel
from config.database import get_neo4j_driver, get_postgres_pool, get_redis_client
from services.session_planner import SessionPlanner
from services.tutor import TutorService
from models.events import TurnSignal

async def test():
    neo4j = get_neo4j_driver()
    pool = await get_postgres_pool()
    redis = await get_redis_client()
    kernel = build_kernel()
    
    planner = SessionPlanner(kernel, neo4j, pool, redis)
    tutor = TutorService(kernel, neo4j, pool, redis, None)
    
    # Create a plan
    plan = await planner.create_plan(
        student_id="test_student",
        session_id="test_session_001",
        chapter="electrostatics"
    )
    print(f"Plan created: {plan.session_goal}")
    
    # Send one message
    signal = TurnSignal(
        response_latency_ms=3000,
        hint_requested=False,
        answer_changed=False,
        consecutive_wrong=0,
        consecutive_correct=0
    )
    response, event = await tutor.process_message(
        session_id="test_session_001",
        student_id="test_student",
        message="I want to start with Gauss's Law",
        turn_signal=signal
    )
    print(f"Tutor response: {response[:200]}...")
    
    await neo4j.close()
    await pool.close()
    await redis.close()

asyncio.run(test())