# backend/models — SUMMARY

## Current State
This folder contains the core Pydantic data models for the Prisma AI application, including `SessionPlan` and `QuestionSpec`, defining schema bounds and default fields used throughout the system.

## Last Action
Modified `models/session.py` `SessionPlan` class to update `max_exchanges` default to 20 and introduced a new `total_duration_minutes` field (set to 25) effectively defining longer session durations.

## Dependencies
- Pydantic models are foundational and depend only on each other (e.g., `models.errors.ErrorType`).

## Next Steps
- Expose the updated length/duration parameters natively through the session-fetching FastAPI routes.
