"""Live test: run several neo4j_service queries against the seeded graph."""
import asyncio
import os
import json
from dotenv import load_dotenv
from neo4j import AsyncGraphDatabase

load_dotenv()

# Add parent to path for imports
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from db.neo4j_service import (
    get_student_weak_concepts,
    find_prerequisite_chain,
    find_confusion_pair,
    find_general_principle,
    find_analogy_bridge,
    find_discrimination_pair,
    find_problem_types_for_concept,
    get_viewport_with_rich_context,
    update_mastery_score,
)


async def test():
    driver = AsyncGraphDatabase.driver(
        os.getenv("NEO4J_URI"),
        auth=(os.getenv("NEO4J_USER"), os.getenv("NEO4J_PASSWORD")),
    )

    print("=" * 60)
    print("TEST 1: get_student_weak_concepts (fallback — new student)")
    print("=" * 60)
    result = await get_student_weak_concepts(driver, "test_student_1", "electrostatics")
    for r in result[:3]:
        print(f"  {r['concept_id']:35s} difficulty={r['difficulty']}")
    print(f"  ... {len(result)} total concepts returned\n")

    print("=" * 60)
    print("TEST 2: find_prerequisite_chain('series_rlc_circuit')")
    print("=" * 60)
    result = await find_prerequisite_chain(driver, "test_student_1", "series_rlc_circuit")
    for r in result[:5]:
        print(f"  depth={r['depth']}  {r['concept_id']:35s}")
    print(f"  ... {len(result)} prereqs found\n")

    print("=" * 60)
    print("TEST 3: find_confusion_pair('gauss_law')")
    print("=" * 60)
    result = await find_confusion_pair(driver, "test_student_1", "gauss_law")
    for r in result:
        print(f"  {r['concept_id']:35s}  {r.get('common_misconceptions', 'n/a')}")
    print(f"  ... {len(result)} confusion pairs\n")

    print("=" * 60)
    print("TEST 4: find_general_principle('motional_emf')")
    print("=" * 60)
    result = await find_general_principle(driver, "test_student_1", "motional_emf")
    for r in result:
        print(f"  {r['concept_id']:35s}  mastery={r['general_mastery']}")
    print(f"  ... {len(result)} general principles\n")

    print("=" * 60)
    print("TEST 5: find_discrimination_pair('diamagnetism')")
    print("=" * 60)
    result = await find_discrimination_pair(driver, "test_student_1", "diamagnetism")
    for r in result:
        print(f"  {r['concept_id']:35s}  dim={r.get('contrast_dimension', 'n/a')}")
    print(f"  ... {len(result)} contrasts\n")

    print("=" * 60)
    print("TEST 6: find_problem_types_for_concept('coulombs_law')")
    print("=" * 60)
    result = await find_problem_types_for_concept(driver, "test_student_1", "coulombs_law")
    for pt in result["problem_types"]:
        print(f"  PT: {pt['name']:40s}  freq={pt.get('jee_frequency', 'n/a')}")
    print(f"  Co-concepts: {len(result['co_concepts'])}\n")

    print("=" * 60)
    print("TEST 7: get_viewport_with_rich_context (fallback)")
    print("=" * 60)
    result = await get_viewport_with_rich_context(driver, "test_student_1", "current_electricity")
    print(f"  is_fallback: {result['is_fallback']}")
    print(f"  viewport items: {len(result['viewport'])}")
    if result['viewport']:
        r = result['viewport'][0]
        print(f"  first: {r['concept_id']}, confusion_neighbors={r['confusion_neighbors']}")
    print()

    await driver.close()
    print("All tests passed!")


asyncio.run(test())
