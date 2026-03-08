"""Prisma AI — Knowledge Graph Plugin for Semantic Kernel.

Wraps neo4j_service.py query functions as @kernel_function methods.
The Tutor Agent calls these tools based on its error classification.

Rules:
  - All parameters are str (Semantic Kernel serialises everything).
  - All return types are str (json.dumps of the query result).
  - update_mastery is NOT exposed here — mastery writes happen only
    at session end from the service layer.
"""

import json
from typing import Annotated

from neo4j import AsyncDriver
from semantic_kernel.functions import kernel_function

from db import neo4j_service


class KnowledgeGraphPlugin:
    """Semantic Kernel plugin that exposes Neo4j KG queries to the Tutor Agent."""

    def __init__(self, driver: AsyncDriver):
        self._driver = driver

    # ── Q1 ────────────────────────────────────────────────────────────────
    @kernel_function(
        description=(
            "Call when student fails a concept due to missing foundational knowledge. "
            "Returns prerequisite concepts with low mastery, ordered by proximity. "
            "Error type: PREREQUISITE_GAP"
        )
    )
    async def find_prerequisite_gaps(
        self,
        student_id: Annotated[str, "The student's unique ID"],
        concept_id: Annotated[str, "The concept the student is struggling with"],
    ) -> str:
        result = await neo4j_service.find_prerequisite_chain(
            self._driver, student_id, concept_id
        )
        return json.dumps(result, default=str)

    # ── Q2 ────────────────────────────────────────────────────────────────
    @kernel_function(
        description=(
            "Call when student applies a correct method for the WRONG concept. "
            "Systematic substitution errors. Returns the likely confused concept pair. "
            "Error type: CONFUSION_ERROR"
        )
    )
    async def find_confusion_pair(
        self,
        student_id: Annotated[str, "The student's unique ID"],
        concept_id: Annotated[str, "The concept the student confused with another"],
    ) -> str:
        result = await neo4j_service.find_confusion_pair(
            self._driver, student_id, concept_id
        )
        return json.dumps(result, default=str)

    # ── Q3 ────────────────────────────────────────────────────────────────
    @kernel_function(
        description=(
            "Call when student solves standard problems but fails variants. "
            "Returns the general principle the student is missing. "
            "Error type: SPECIAL_CASE_FIXATION"
        )
    )
    async def find_general_principle(
        self,
        student_id: Annotated[str, "The student's unique ID"],
        concept_id: Annotated[str, "The special-case concept the student is fixated on"],
    ) -> str:
        result = await neo4j_service.find_general_principle(
            self._driver, student_id, concept_id
        )
        return json.dumps(result, default=str)

    # ── Q4 ────────────────────────────────────────────────────────────────
    @kernel_function(
        description=(
            "Call when student has zero mastery on a concept but high mastery "
            "on an analogous concept in another chapter. Returns the bridge concept. "
            "Error type: ANALOGICAL_TRANSFER_FAILURE"
        )
    )
    async def find_analogy_bridge(
        self,
        student_id: Annotated[str, "The student's unique ID"],
        weak_concept_id: Annotated[str, "The concept the student has not yet learned"],
    ) -> str:
        result = await neo4j_service.find_analogy_bridge(
            self._driver, student_id, weak_concept_id
        )
        return json.dumps(result, default=str)

    # ── Q5 ────────────────────────────────────────────────────────────────
    @kernel_function(
        description=(
            "Call when student knows both concepts individually but fails combined problems. "
            "Returns co-occurring concepts and the problem types where they appear together. "
            "Error type: COORDINATION_FAILURE"
        )
    )
    async def find_coordination_pair(
        self,
        student_id: Annotated[str, "The student's unique ID"],
        concept_id: Annotated[str, "One of the concepts that should be coordinated"],
    ) -> str:
        result = await neo4j_service.find_coordination_concepts(
            self._driver, student_id, concept_id
        )
        return json.dumps(result, default=str)

    # ── Q6 ────────────────────────────────────────────────────────────────
    @kernel_function(
        description=(
            "Call when student alternates between two answers for the same type of problem. "
            "Returns the contrasting concept and the discriminating dimension. "
            "Error type: DISCRIMINATION_FAILURE"
        )
    )
    async def find_discrimination_pair(
        self,
        student_id: Annotated[str, "The student's unique ID"],
        concept_id: Annotated[str, "The concept the student oscillates on"],
    ) -> str:
        result = await neo4j_service.find_discrimination_pair(
            self._driver, student_id, concept_id
        )
        return json.dumps(result, default=str)

    # ── Q7 ────────────────────────────────────────────────────────────────
    @kernel_function(
        description=(
            "Call when student knows the concept but doesn't know what kind of JEE "
            "problem tests it. Returns problem type templates for the concept. "
            "Error type: PROBLEM_TYPE_UNFAMILIARITY"
        )
    )
    async def find_problem_types(
        self,
        concept_id: Annotated[str, "The concept the student knows but can't apply"],
        student_id: Annotated[str, "The student's unique ID"],
    ) -> str:
        result = await neo4j_service.find_problem_types_for_concept(
            self._driver, student_id, concept_id
        )
        return json.dumps(result, default=str)

    # ── Q8 ────────────────────────────────────────────────────────────────
    @kernel_function(
        description=(
            "Call when student can recall formula but fails transfer problems. "
            "Returns the deeper general principle and harder problem types. "
            "Error type: SURFACE_KNOWLEDGE"
        )
    )
    async def find_transfer_challenge(
        self,
        student_id: Annotated[str, "The student's unique ID"],
        concept_id: Annotated[str, "The concept the student only knows superficially"],
    ) -> str:
        result = await neo4j_service.find_transfer_problems(
            self._driver, student_id, concept_id
        )
        return json.dumps(result, default=str)
