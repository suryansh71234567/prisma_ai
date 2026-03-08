"""Prisma AI — Neo4j Cypher query layer.

ALL Cypher queries live here and nowhere else.
No business logic, no LLM calls, no plugin registration.

Node types : Concept, Chapter, ProblemType, Student
Edge types : REQUIRES, COMMONLY_CONFUSED_WITH, ANALOGY_OF,
             GENERALIZES, USED_TOGETHER, CONTRASTS_WITH,
             APPEARS_IN_PROBLEM_TYPE, EXTENDS, HAS_MASTERY,
             IS_PART_OF

Query index (maps to kg_schema_extended.md §Part 6):
  Q1  find_prerequisite_chain     → PREREQUISITE_GAP
  Q2  find_confusion_pair         → CONFUSION_ERROR
  Q3  find_general_principle      → SPECIAL_CASE_FIXATION
  Q4  find_analogy_bridge         → ANALOGICAL_TRANSFER_FAILURE
  Q5  find_coordination_concepts  → COORDINATION_FAILURE
  Q6  find_discrimination_pair    → DISCRIMINATION_FAILURE
  Q7  find_problem_types          → PROBLEM_TYPE_UNFAMILIARITY  (two-step)
  Q8  find_transfer_problems      → SURFACE_KNOWLEDGE
  Q9  get_viewport_with_rich_context → Dashboard / session start
  Q10 find_opportunity_concepts   → Student performing well

Utility:
  get_student_weak_concepts  — fallback-aware weak-concept list
  update_mastery_score       — upsert HAS_MASTERY edge
"""

from typing import Any, Dict, List

import neo4j
from neo4j import AsyncDriver


# ---------------------------------------------------------------------------
# Utility — Weak concepts for a student in a chapter
# ---------------------------------------------------------------------------
async def get_student_weak_concepts(
    driver: AsyncDriver,
    student_id: str,
    chapter: str,
    threshold: float = 0.6,
    limit: int = 8,
) -> List[dict]:
    """Return the student's weakest concepts in *chapter*.

    Falls back to all chapter concepts (mastery = 0.0) when the student
    has no HAS_MASTERY edges for the chapter yet.

    Returns:
        List of dicts: concept_id, name, chapter, difficulty, mastery_score
        — ordered weakest-first.
    """

    primary_query = """
        MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(c:Concept)
        WHERE c.chapter = $chapter AND m.score < $threshold
        RETURN c.id         AS concept_id,
               c.name       AS name,
               c.chapter    AS chapter,
               c.difficulty AS difficulty,
               m.score      AS mastery_score
        ORDER BY m.score ASC
        LIMIT $limit
    """

    records, _, _ = await driver.execute_query(
        primary_query,
        student_id=student_id,
        chapter=chapter,
        threshold=threshold,
        limit=limit,
    )

    if records:
        return [record.data() for record in records]

    # Fallback: no mastery edges yet — return chapter concepts sorted by difficulty
    fallback_query = """
        MATCH (c:Concept)
        WHERE c.chapter = $chapter
        RETURN c.id         AS concept_id,
               c.name       AS name,
               c.chapter    AS chapter,
               c.difficulty AS difficulty,
               0.0          AS mastery_score
        ORDER BY c.difficulty ASC
        LIMIT $limit
    """

    records, _, _ = await driver.execute_query(
        fallback_query,
        chapter=chapter,
        limit=limit,
    )

    return [record.data() for record in records]


# ---------------------------------------------------------------------------
# Q1: Prerequisite chain   → PREREQUISITE_GAP
# ---------------------------------------------------------------------------
async def find_prerequisite_chain(
    driver: AsyncDriver,
    student_id: str,
    concept_id: str,
    max_depth: int = 5,
) -> List[dict]:
    """Traverse REQUIRES edges up to *max_depth* hops.

    Returns only prerequisites where student mastery < 0.6 (or never seen).
    Ordered shallowest-gap-first.
    """

    # Cypher cannot parameterise variable-length bounds; safe int embed.
    query = f"""
        MATCH path = (start:Concept {{id: $concept_id}})-[:REQUIRES*1..{int(max_depth)}]->(prereq:Concept)
        OPTIONAL MATCH (s:Student {{id: $student_id}})-[m:HAS_MASTERY]->(prereq)
        WITH prereq,
             min(length(path)) AS depth,
             COALESCE(m.score, 0.0) AS mastery_score
        WHERE mastery_score < 0.6
        RETURN prereq.id      AS concept_id,
               prereq.name    AS name,
               prereq.chapter AS chapter,
               depth,
               mastery_score
        ORDER BY depth ASC
    """

    records, _, _ = await driver.execute_query(
        query,
        concept_id=concept_id,
        student_id=student_id,
    )

    return [record.data() for record in records]


# ---------------------------------------------------------------------------
# Q2: Confusion pair   → CONFUSION_ERROR
# ---------------------------------------------------------------------------
async def find_confusion_pair(
    driver: AsyncDriver,
    student_id: str,
    concept_id: str,
) -> List[dict]:
    """Find concepts commonly confused with *concept_id*.

    Uses undirected match so both COMMONLY_CONFUSED_WITH directions
    are captured.  Also returns the student's mastery on each confused
    neighbour.
    """

    query = """
        MATCH (c:Concept {id: $concept_id})-[:COMMONLY_CONFUSED_WITH]-(other:Concept)
        OPTIONAL MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(other)
        RETURN other.id                    AS concept_id,
               other.name                  AS name,
               other.chapter               AS chapter,
               other.common_misconceptions AS common_misconceptions,
               COALESCE(m.score, 0.0)      AS mastery_score
    """

    records, _, _ = await driver.execute_query(
        query,
        concept_id=concept_id,
        student_id=student_id,
    )

    return [record.data() for record in records]


# ---------------------------------------------------------------------------
# Q3: General principle   → SPECIAL_CASE_FIXATION
# ---------------------------------------------------------------------------
async def find_general_principle(
    driver: AsyncDriver,
    student_id: str,
    concept_id: str,
) -> List[dict]:
    """Find the general concept(s) that *concept_id* is a special case of.

    Uses the GENERALIZES edge: (general)-[:GENERALIZES]->(special).
    Surfaces gaps where the student masters the special case but not the
    underlying principle.
    """

    query = """
        MATCH (general:Concept)-[:GENERALIZES]->(special:Concept {id: $concept_id})
        OPTIONAL MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(general)
        RETURN general.id                    AS concept_id,
               general.name                  AS name,
               general.chapter               AS chapter,
               general.difficulty            AS difficulty,
               COALESCE(m.score, 0.0)        AS general_mastery,
               general.common_misconceptions AS common_misconceptions
        ORDER BY general_mastery ASC
    """

    records, _, _ = await driver.execute_query(
        query,
        concept_id=concept_id,
        student_id=student_id,
    )

    return [record.data() for record in records]


# ---------------------------------------------------------------------------
# Q4: Analogy bridge   → ANALOGICAL_TRANSFER_FAILURE
# ---------------------------------------------------------------------------
async def find_analogy_bridge(
    driver: AsyncDriver,
    student_id: str,
    weak_concept_id: str,
) -> List[dict]:
    """Find analogous concepts the student *already* masters (> 0.7).

    Returns the bridge concept, mapping metadata, and both mastery scores.
    """

    query = """
        MATCH (weak:Concept {id: $weak_concept_id})-[r:ANALOGY_OF]->(bridge:Concept)
        MATCH (s:Student {id: $student_id})-[bm:HAS_MASTERY]->(bridge)
        WHERE bm.score > 0.7
        OPTIONAL MATCH (s)-[wm:HAS_MASTERY]->(weak)
        RETURN bridge.id                AS concept_id,
               bridge.name              AS name,
               bridge.chapter           AS chapter,
               bm.score                 AS bridge_mastery,
               COALESCE(wm.score, 0.0)  AS weak_mastery,
               r.strength               AS analogy_strength,
               r.domain                 AS analogy_domain
        ORDER BY bm.score DESC, r.strength DESC
        LIMIT 2
    """

    records, _, _ = await driver.execute_query(
        query,
        weak_concept_id=weak_concept_id,
        student_id=student_id,
    )

    return [record.data() for record in records]


# ---------------------------------------------------------------------------
# Q5: Coordination concepts   → COORDINATION_FAILURE
# ---------------------------------------------------------------------------
async def find_coordination_concepts(
    driver: AsyncDriver,
    student_id: str,
    concept_id: str,
) -> List[dict]:
    """Find concepts that co-occur with *concept_id* in problems.

    Fires when the student masters each individually (> 0.65) but fails
    combined problems.
    """

    query = """
        MATCH (target:Concept {id: $concept_id})-[r:USED_TOGETHER]-(partner:Concept)
        MATCH (s:Student {id: $student_id})-[pm:HAS_MASTERY]->(partner)
        MATCH (s)-[tm:HAS_MASTERY]->(target)
        WHERE pm.score > 0.65 AND tm.score > 0.65
        RETURN partner.id          AS concept_id,
               partner.name        AS name,
               partner.chapter     AS chapter,
               pm.score            AS partner_mastery,
               tm.score            AS target_mastery,
               r.frequency         AS co_occurrence_frequency,
               r.problem_type      AS problem_context
        ORDER BY r.frequency DESC
        LIMIT 5
    """

    records, _, _ = await driver.execute_query(
        query,
        concept_id=concept_id,
        student_id=student_id,
    )

    return [record.data() for record in records]


# ---------------------------------------------------------------------------
# Q6: Discrimination pair   → DISCRIMINATION_FAILURE
# ---------------------------------------------------------------------------
async def find_discrimination_pair(
    driver: AsyncDriver,
    student_id: str,
    concept_id: str,
) -> List[dict]:
    """Find CONTRASTS_WITH neighbours and the dimension of contrast.

    Fires when the student alternates between two answers for the same
    problem type.
    """

    query = """
        MATCH (target:Concept {id: $concept_id})-[r:CONTRASTS_WITH]-(contrast:Concept)
        OPTIONAL MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(contrast)
        RETURN contrast.id               AS concept_id,
               contrast.name             AS name,
               contrast.chapter          AS chapter,
               r.dimension               AS contrast_dimension,
               COALESCE(m.score, 0.0)    AS contrast_mastery
        ORDER BY contrast_mastery ASC
    """

    records, _, _ = await driver.execute_query(
        query,
        concept_id=concept_id,
        student_id=student_id,
    )

    return [record.data() for record in records]


# ---------------------------------------------------------------------------
# Q7: Problem types for a concept   → PROBLEM_TYPE_UNFAMILIARITY
# ---------------------------------------------------------------------------
async def find_problem_types_for_concept(
    driver: AsyncDriver,
    student_id: str,
    concept_id: str,
) -> Dict[str, Any]:
    """Two-step query:

    Step 1 — fetch JEE problem types that test *concept_id*.
    Step 2 — for each problem type, fetch co-concepts and student mastery.

    Returns dict with keys: problem_types, co_concepts.
    """

    # Step 1
    pt_query = """
        MATCH (target:Concept {id: $concept_id})-[:APPEARS_IN_PROBLEM_TYPE]->(pt:ProblemType)
        RETURN pt.id            AS problem_type_id,
               pt.name          AS name,
               pt.difficulty    AS difficulty,
               pt.jee_frequency AS jee_frequency,
               pt.key_concepts  AS key_concepts,
               pt.typical_traps AS typical_traps
        ORDER BY pt.jee_frequency DESC
        LIMIT 4
    """

    pt_records, _, _ = await driver.execute_query(
        pt_query,
        concept_id=concept_id,
    )

    problem_types = [r.data() for r in pt_records]

    # Step 2 — co-concepts
    co_query = """
        MATCH (target:Concept {id: $concept_id})-[:APPEARS_IN_PROBLEM_TYPE]->(pt:ProblemType)
        MATCH (other:Concept)-[:APPEARS_IN_PROBLEM_TYPE]->(pt)
        WHERE other.id <> $concept_id
        OPTIONAL MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(other)
        RETURN other.id                  AS concept_id,
               other.name               AS name,
               COALESCE(m.score, 0.0)   AS mastery,
               pt.id                    AS problem_type
        ORDER BY pt.jee_frequency DESC, mastery ASC
        LIMIT 10
    """

    co_records, _, _ = await driver.execute_query(
        co_query,
        concept_id=concept_id,
        student_id=student_id,
    )

    co_concepts = [r.data() for r in co_records]

    return {"problem_types": problem_types, "co_concepts": co_concepts}


# ---------------------------------------------------------------------------
# Q8: Transfer problems   → SURFACE_KNOWLEDGE
# ---------------------------------------------------------------------------
async def find_transfer_problems(
    driver: AsyncDriver,
    student_id: str,
    concept_id: str,
) -> List[dict]:
    """Find the general principle behind *concept_id* and harder problem types
    that test that principle (not the special case).

    Fires when student can recall formula but fails transfer problems.
    """

    query = """
        MATCH (general:Concept)-[:GENERALIZES]->(target:Concept {id: $concept_id})
        OPTIONAL MATCH (s:Student {id: $student_id})-[gm:HAS_MASTERY]->(general)
        WITH general, COALESCE(gm.score, 0.0) AS general_mastery
        WHERE general_mastery < 0.7
        MATCH (general)-[:APPEARS_IN_PROBLEM_TYPE]->(hard_pt:ProblemType)
        RETURN general.id        AS principle_id,
               general.name      AS principle_name,
               general_mastery,
               hard_pt.id        AS problem_type_id,
               hard_pt.name      AS problem_type_name,
               hard_pt.difficulty AS difficulty,
               hard_pt.typical_traps AS typical_traps
        ORDER BY hard_pt.difficulty ASC
        LIMIT 3
    """

    records, _, _ = await driver.execute_query(
        query,
        concept_id=concept_id,
        student_id=student_id,
    )

    return [record.data() for record in records]


# ---------------------------------------------------------------------------
# Q9: Viewport with rich context   → Dashboard / session start
# ---------------------------------------------------------------------------
async def get_viewport_with_rich_context(
    driver: AsyncDriver,
    student_id: str,
    chapter: str,
    mastery_threshold: float = 0.6,
) -> Dict[str, Any]:
    """Full enriched subgraph for the session planner.

    Returns weak concepts, their prerequisite gaps (≤3 hops),
    and confusion neighbours — all in one payload.  Falls back to
    chapter overview when the student has no mastery data yet.
    """

    # ── Primary: student has mastery edges ──
    primary_query = """
        MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(c:Concept)
        WHERE c.chapter = $chapter AND m.score < $mastery_threshold
        OPTIONAL MATCH path = (c)-[:REQUIRES*1..3]->(prereq:Concept)
        OPTIONAL MATCH (s)-[pm:HAS_MASTERY]->(prereq)
        OPTIONAL MATCH (c)-[:COMMONLY_CONFUSED_WITH]-(confused:Concept)
        RETURN c.id            AS concept_id,
               c.name          AS name,
               c.difficulty    AS difficulty,
               m.score         AS mastery,
               prereq.id       AS prereq_id,
               prereq.name     AS prereq_name,
               COALESCE(pm.score, 0.0) AS prereq_mastery,
               collect(DISTINCT confused.id) AS confusion_neighbors
        LIMIT 50
    """

    records, _, _ = await driver.execute_query(
        primary_query,
        student_id=student_id,
        chapter=chapter,
        mastery_threshold=mastery_threshold,
    )

    if records:
        return {"viewport": [r.data() for r in records], "is_fallback": False}

    # ── Fallback: new student, no mastery ──
    fallback_query = """
        MATCH (c:Concept)
        WHERE c.chapter = $chapter
        OPTIONAL MATCH (c)-[:COMMONLY_CONFUSED_WITH]-(confused:Concept)
        RETURN c.id            AS concept_id,
               c.name          AS name,
               c.difficulty    AS difficulty,
               0.0             AS mastery,
               null            AS prereq_id,
               null            AS prereq_name,
               0.0             AS prereq_mastery,
               collect(DISTINCT confused.id) AS confusion_neighbors
        ORDER BY c.difficulty ASC
        LIMIT 50
    """

    records, _, _ = await driver.execute_query(
        fallback_query,
        chapter=chapter,
    )

    return {"viewport": [r.data() for r in records], "is_fallback": True}


# ---------------------------------------------------------------------------
# Q10: Opportunity concepts   → Student performing well
# ---------------------------------------------------------------------------
async def find_opportunity_concepts(
    driver: AsyncDriver,
    student_id: str,
    chapter: str,
) -> List[dict]:
    """Find next-challenge concepts reachable via ANALOGY_OF or EXTENDS
    from concepts the student has already mastered (> 0.8).

    Returns concepts with low mastery (< 0.5) in the target chapter.
    """

    query = """
        MATCH (s:Student {id: $student_id})-[m:HAS_MASTERY]->(mastered:Concept)
        WHERE m.score > 0.8
        MATCH (next:Concept)-[r:ANALOGY_OF]->(mastered)
        WHERE r.strength > 0.7
        OPTIONAL MATCH (s)-[nm:HAS_MASTERY]->(next)
        WITH next, COALESCE(nm.score, 0.0) AS next_mastery,
             mastered, r.strength AS analogy_strength
        WHERE next_mastery < 0.5 AND next.chapter = $chapter
        RETURN next.id           AS concept_id,
               next.name         AS name,
               next.chapter      AS chapter,
               next.difficulty   AS difficulty,
               next_mastery,
               mastered.id       AS bridge_from,
               analogy_strength
        ORDER BY analogy_strength DESC, next.difficulty ASC
        LIMIT 5
    """

    records, _, _ = await driver.execute_query(
        query,
        student_id=student_id,
        chapter=chapter,
    )

    return [record.data() for record in records]


# ---------------------------------------------------------------------------
# Utility — Upsert mastery score
# ---------------------------------------------------------------------------
async def update_mastery_score(
    driver: AsyncDriver,
    student_id: str,
    concept_id: str,
    score: float,
) -> None:
    """Upsert the HAS_MASTERY edge between a Student and a Concept.

    Validates that *score* is in [0.0, 1.0] before writing.

    Raises:
        ValueError: If *score* is outside the 0.0–1.0 range.
    """

    if not (0.0 <= score <= 1.0):
        raise ValueError(f"score must be between 0.0 and 1.0, got {score}")

    query = """
        MERGE (s:Student {id: $student_id})
        MERGE (c:Concept {id: $concept_id})
        MERGE (s)-[m:HAS_MASTERY]->(c)
        SET m.score = $score, m.last_seen = datetime()
    """

    await driver.execute_query(
        query,
        student_id=student_id,
        concept_id=concept_id,
        score=score,
        routing_=neo4j.RoutingControl.WRITE,
    )


# ---------------------------------------------------------------------------
# Planner viewport: weak concepts + their graph neighbourhood
# ---------------------------------------------------------------------------
async def get_weak_concepts_with_edges(
    driver: AsyncDriver,
    student_id: str,
    chapter: str,
) -> dict:
    """Planner viewport query — returns weak concepts together with their
    COMMONLY_CONFUSED_WITH and ANALOGY_OF neighbours.

    Returns:
        Dict with keys:
        - weak_concepts   : list[dict]
        - confusion_pairs : list[dict] with source_id, edge_type,
                            neighbor_id, neighbor_name, analogy_mapping
        - analogy_bridges : list[dict] same shape, filtered to ANALOGY_OF
    """

    # Query A — top 8 weak concepts
    weak_concepts = await get_student_weak_concepts(
        driver, student_id, chapter,
    )

    if not weak_concepts:
        return {
            "weak_concepts": [],
            "confusion_pairs": [],
            "analogy_bridges": [],
        }

    concept_ids = [c["concept_id"] for c in weak_concepts]

    # Query B — neighbourhood edges
    edge_query = """
        MATCH (c:Concept)-[r:COMMONLY_CONFUSED_WITH|ANALOGY_OF]-(neighbor:Concept)
        WHERE c.id IN $concept_ids
        RETURN c.id        AS source_id,
               type(r)     AS edge_type,
               neighbor.id   AS neighbor_id,
               neighbor.name AS neighbor_name,
               r.mapping     AS analogy_mapping
    """

    records, _, _ = await driver.execute_query(
        edge_query,
        concept_ids=concept_ids,
    )

    confusion_pairs = []
    analogy_bridges = []

    for record in records:
        row = record.data()
        if row["edge_type"] == "COMMONLY_CONFUSED_WITH":
            confusion_pairs.append(row)
        elif row["edge_type"] == "ANALOGY_OF":
            analogy_bridges.append(row)

    return {
        "weak_concepts": weak_concepts,
        "confusion_pairs": confusion_pairs,
        "analogy_bridges": analogy_bridges,
    }


# ---------------------------------------------------------------------------
# Planner context alias
# ---------------------------------------------------------------------------
async def get_planner_context(
    driver: AsyncDriver,
    student_id: str,
    chapter: str,
) -> dict:
    """Alias for get_weak_concepts_with_edges.

    Called by session_planner.py at session start.
    Returns weak_concepts, confusion_pairs, and analogy_bridges
    for the given student and chapter.
    """
    return await get_weak_concepts_with_edges(driver, student_id, chapter)


# ---------------------------------------------------------------------------
# Registration helper — ensure Student node exists in Neo4j
# ---------------------------------------------------------------------------
async def create_student_node(driver, student_id: str) -> None:
    """
    Creates a Student node in Neo4j if it doesn't already exist.
    Called once at registration. Safe to call multiple times (MERGE).
    """
    await driver.execute_query(
        "MERGE (:Student {id: $student_id})",
        student_id=student_id
    )


# ---------------------------------------------------------------------------
# Registration helper — initialize HAS_MASTERY edges for all concepts
# ---------------------------------------------------------------------------
async def initialize_student_mastery(driver, student_id: str) -> int:
    """
    Creates HAS_MASTERY edges from the Student node to ALL Concept
    nodes with random initial scores.
    Called once at registration after create_student_node().
    Returns the number of concepts initialized.

    Distribution: normal, mean=0.5, std=0.12, clamped to [0.1, 0.8].
    Never starts at 0 (too discouraging for planner) or above 0.8
    (student hasn't proven mastery yet).
    """
    import random

    # Step 1: fetch all concept ids from the graph
    result = await driver.execute_query(
        "MATCH (c:Concept) RETURN c.id AS concept_id"
    )
    concept_ids = [r["concept_id"] for r in result.records]

    if not concept_ids:
        print("WARNING: No concepts found in graph. "
              "Did you run the seed script?")
        return 0

    # Step 2: generate scores — normal distribution clamped to [0.1, 0.8]
    scores = []
    for _ in concept_ids:
        raw = random.gauss(0.5, 0.12)
        clamped = max(0.1, min(0.8, raw))
        scores.append(round(clamped, 3))

    # Step 3: write all HAS_MASTERY edges in one batch query
    # UNWIND keeps this a single round trip regardless of concept count
    await driver.execute_query(
        """
        UNWIND $updates AS update
        MATCH (s:Student {id: $student_id})
        MATCH (c:Concept {id: update.concept_id})
        MERGE (s)-[m:HAS_MASTERY]->(c)
        SET m.score = update.score,
            m.last_seen = datetime(),
            m.attempt_count = 0
        """,
        student_id=student_id,
        updates=[
            {"concept_id": cid, "score": score}
            for cid, score in zip(concept_ids, scores)
        ],
        routing_=neo4j.RoutingControl.WRITE,
    )

    print(f"Initialized mastery for {len(concept_ids)} concepts. "
          f"Score range: {min(scores):.3f} – {max(scores):.3f}, "
          f"mean: {sum(scores)/len(scores):.3f}")

    return len(concept_ids)
