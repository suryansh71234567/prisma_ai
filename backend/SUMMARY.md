# backend — SUMMARY

## Current State
The backend directory contains the main orchestration logic, data repositories, services, and routing system for Prisma AI. It uses FastAPI for the API layer and integrates Semantic Kernel for Socratic physics tutoring, backed by Neo4j (Knowledge Graph), PostgreSQL (Relational state), and Redis (Caching).

## Last Action
Created `main.py`, introducing the FastAPI application entrypoint. Configured CORS, the `lifespan` context manager, and initialized the application state. Instantiated PostgreSQL, Redis, Neo4j, VectorStore, and the single instance of the LLM `kernel`. Finally, injected the `SessionPlanner`, `TutorService`, and `Summarizer` singletons into `app.state`, and mapped the `auth_router` and `session_router`.

## Dependencies
- `config/` -> `database.py` (DB instances), `llm_provider.py` (SK Kernel instantiation)
- `db/` -> `postgres_service.py` (executing table DDL `CREATE_TABLES_SQL` at startup)
- `services/` -> `session_planner.py`, `tutor.py`, `summarizer.py`, `vector_store.py` (instantiated and attached to state)
- `routes/` -> `auth.py`, `session.py` (included as API routes)

## Next Steps
- Execute `uvicorn backend.main:app --reload --port 8000` to start up the FastAPI server and monitor for clean boots.
- Begin functional integration testing via API requests to the local server.
