# backend/services — SUMMARY

## Current State
The services layer contains orchestration logic for the Prisma AI tutoring system: a Socratic tutor loop (`tutor.py`), a session planner (`session_planner.py`), an end-of-session summarizer (`summarizer.py`), a knowledge-graph builder stub (`kg_builder.py`), and a vector-store service (`vector_store.py`). All services use Semantic Kernel for LLM interaction and delegate data access to the `db/` layer.

## Last Action
Modified `session_planner.py` to update the LLM prompt for generating 25-minute study plans rather than 5-minute plans. Increased the `max_exchanges` default logic from 5 to 20. Added detailed time-budget phase logic (INTRO, DEFINITION, EXAMPLES, LOGICAL_QUESTIONS, PROBLEM, WRAP_UP), adjusting dynamically based on student error types (e.g., PREREQUISITE_GAP, SURFACE_KNOWLEDGE).

## Dependencies
- `db/redis_service.py` → `flush_history_to_dict()`
- `db/postgres_service.py` → `get_session_count_today()`
- `config/llm_provider.py` → provides the `Kernel` instance
- `models/session.py` → `SessionPlan`

## Next Steps
- Continue refining phase budget heuristics based on deeper analysis of student errors.
- Ensure the React UI correctly reads `max_exchanges` and `total_duration_minutes` from the parsed `SessionPlan`.
