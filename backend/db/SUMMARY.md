# SUMMARY — backend/db/

## Current State
Contains the Neo4j query layer (`neo4j_service.py`), PostgreSQL query layer (`postgres_service.py`), and Redis cache layer (`redis_service.py`). The Neo4j service has 13 functions. `redis_service.py` now has 9 functions including event-list helpers.

## Last Action
Added `append_exchange_event` (function 8) and `get_and_clear_exchange_events` (function 9) to `redis_service.py`. Both use the `session:{session_id}:events` key with 2-hour TTL. Updated the module docstring to document the new key pattern. No existing functions were touched.

## Dependencies
- `neo4j` async driver (from `config/database.py`)
- Seeded Neo4j graph: 161 Concepts, 14 Chapters, 10 ProblemTypes, 457+ edges
- Will be consumed by `plugins/kg_plugin.py` (Step 5)

## Next Steps
- Build `plugins/kg_plugin.py` — expose these 12 functions as Semantic Kernel `@kernel_function` tools
