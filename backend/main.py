"""Prisma AI — Application Entrypoint.

Initializes the FastAPI application, configures CORS, handles database connections,
and injects services into the app state via the lifespan context manager.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config.database import get_neo4j_driver, get_postgres_pool, get_redis_client
from config.llm_provider import build_kernel
from db.postgres_service import CREATE_TABLES_SQL
from routes.auth import router as auth_router
from routes.session import router as session_router

from services.session_planner import SessionPlanner
from services.tutor import TutorService
from services.summarizer import Summarizer
from services.vector_store import VectorStore


@asynccontextmanager
async def lifespan(app: FastAPI):
    # STARTUP
    print("Starting Prisma AI...")

    # 1. Connect databases
    app.state.neo4j = get_neo4j_driver()
    app.state.pool = await get_postgres_pool()
    app.state.redis = await get_redis_client()

    # 2. Create tables (idempotent)
    async with app.state.pool.acquire() as conn:
        await conn.execute(CREATE_TABLES_SQL)
    print("Database tables verified.")

    # 3. Build kernel (single instance, shared across requests)
    kernel = build_kernel()
    app.state.kernel = kernel

    # 4. Load vector store
    vector_store = VectorStore()
    app.state.vector_store = vector_store
    print("Vector store ready.")

    # 5. Instantiate services
    app.state.planner = SessionPlanner(
        kernel=kernel,
        neo4j_driver=app.state.neo4j,
        pool=app.state.pool,
        redis=app.state.redis,
    )
    app.state.tutor = TutorService(
        kernel=kernel,
        neo4j_driver=app.state.neo4j,
        pool=app.state.pool,
        redis=app.state.redis,
        vector_store=vector_store,
    )
    app.state.summarizer = Summarizer(
        kernel=kernel,
        pool=app.state.pool,
        redis=app.state.redis,
    )

    print("All services ready. Prisma AI is running.")

    yield  # app runs here

    # SHUTDOWN
    await app.state.neo4j.close()
    await app.state.pool.close()
    await app.state.redis.close()
    print("Prisma AI shut down cleanly.")


app = FastAPI(
    title="Prisma AI",
    description="JEE tutoring system — AI Study Buddy",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8081"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(session_router)


@app.get("/health")
async def health_check():
    """Health check route (no auth)."""
    return {"status": "ok", "version": "0.1.0"}
