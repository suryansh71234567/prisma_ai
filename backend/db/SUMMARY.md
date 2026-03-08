# SUMMARY — backend/db/

## Current State
Contains the Neo4j query layer (`neo4j_service.py`), PostgreSQL query layer (`postgres_service.py`), and Redis cache layer (`redis_service.py`). The Neo4j service has 12 functions covering all 10 schema queries (Q1–Q10) plus 2 utilities.

## Last Action
Rewrote `neo4j_service.py` from 6 functions to 12, aligning with `kg_schema_extended.md` §Part 6. Added Q3 (find_general_principle), Q5 (find_coordination_concepts), Q6 (find_discrimination_pair), Q7 (find_problem_types_for_concept — two-step), Q8 (find_transfer_problems), Q9 (get_viewport_with_rich_context — with fallback), Q10 (find_opportunity_concepts). Enhanced Q2 (find_confusion_pair) to include student_id and mastery lookup.

## Dependencies
- `neo4j` async driver (from `config/database.py`)
- Seeded Neo4j graph: 161 Concepts, 14 Chapters, 10 ProblemTypes, 457+ edges
- Will be consumed by `plugins/kg_plugin.py` (Step 5)

## Next Steps
- Build `plugins/kg_plugin.py` — expose these 12 functions as Semantic Kernel `@kernel_function` tools
