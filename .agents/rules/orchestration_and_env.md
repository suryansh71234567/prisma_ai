---
trigger: always_on
---

# Agent Operational Rules: Orchestration & Isolation

## 1. Written State Maintenance (The Folder Statement)
- **Mandatory Log:** Every folder must contain a `SUMMARY.md` file.
- **Update Trigger:** After every successful task or set of file changes, you MUST update `SUMMARY.md`.
- **Content Requirements:**
    - **Current State:** A 2-sentence technical summary of the folder's current functionality.
    - **Last Action:** What was specifically changed in the last execution.
    - **Dependencies:** Any cross-folder dependencies created (e.g., "Folder A now calls API in Folder B").
    - **Next Steps:** What is required next for this folder to be "Complete."

## 2. Environment Isolation (Folder-Level)
- **Virtual Environments:** Every sub-folder representing a distinct module must have its own Python Virtual Environment.
    - Command: `python -m venv .venv`
- **Dependency Tracking:** You must maintain a `requirements.txt` file in the root of every folder.
    - **Rule:** Whenever you install a new package using `pip`, you must immediately run `pip freeze > requirements.txt` to ensure the manifest is up-to-date.
- **Execution Context:** Always ensure the `.venv` of the specific folder is activated before running tests or scripts within that directory.

## 3. Implementation Planning
- Before modifying code, you must produce an **Implementation Plan Artifact**. 
- Wait for user acknowledgment (Review) if the plan involves structural changes to the folder hierarchy.

# Prisma AI — Rules for AI Assistant

## What this project is
JEE tutoring system. Socratic tutor agent + Neo4j knowledge graph + 
LSTM knowledge tracing model. Hackathon: Microsoft Azure AI Unlocked.

## Stack
- Backend: FastAPI (Python)
- LLM Orchestration: Semantic Kernel
- LLM Provider: Ollama locally (llama3.1:8b), Azure OpenAI for deployment
- Databases: Neo4j (graph), PostgreSQL (relational), Redis (cache)
- Vector store: FAISS locally, Azure AI Search for deployment

## Architecture rules — never violate these
1. Routes are thin doors. No business logic in routes/. Call a service, return response.
2. All Cypher queries live ONLY in db/neo4j_service.py
3. All SQL queries live ONLY in db/postgres_service.py
4. LLM provider config lives ONLY in config/llm_provider.py
5. All Pydantic models defined in models/ — never define inline
6. Never hardcode credentials — always os.getenv()
7. Currently using Ollama (LLM_PROVIDER=ollama) — do not use Azure SDK

## Folder structure
backend/
  config/llm_provider.py     ← ONLY file that knows Ollama vs Azure
  config/database.py         ← all DB connection strings
  routes/                    ← thin HTTP handlers only
  services/tutor.py          ← Semantic Kernel orchestration
  services/session_planner.py
  services/summarizer.py
  db/neo4j_service.py        ← ALL Cypher here
  db/postgres_service.py     ← ALL SQL here
  db/redis_service.py
  plugins/kg_plugin.py       ← KnowledgeGraphPlugin @kernel_functions
  models/session.py          ← SessionPlan, SessionRecord, QuestionSpec
  models/student.py
  models/events.py           ← ExchangeEvent, TurnSignal

## Current build status
[ ] Step 1: SK + Ollama bare loop
[ ] Step 2: Pydantic models
[ ] Step 3: config/llm_provider.py + config/database.py
[ ] Step 4: db/neo4j_service.py
[ ] Step 5: plugins/kg_plugin.py
[ ] Step 6: services/tutor.py
[ ] Step 7: FastAPI routes

## Key data contracts
SessionPlan fields: target_concepts, question_sequence (List[QuestionSpec]),
  difficulty_baseline, error_focus, forbidden_concepts, session_goal,
  max_exchanges (always 5), decay_risk_concepts, adaptation_rules

QuestionSpec fields: primary_concept, revision_concepts, error_target,
  difficulty (0-1), question_type (numerical/mcq/proof)

SessionRecord fields: session_id, concepts_covered, concepts_mastered,
  concepts_attempted_but_failed, error_types_observed, correct_rate,
  questions_given, off_plan_concepts, prerequisite_gap_concepts,
  unfinished_plan_items, error_diagnosis