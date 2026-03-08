"""Prisma AI — Seed the Neo4j knowledge graph from .cypher files.

Usage:
    cd backend
    python -m scripts.seed_neo4j

Reads NEO4J_URI, NEO4J_USER, NEO4J_PASSWORD from .env.
Executes two Cypher files in order:
  1. kg_seed_electrodynamics (1).cypher  — chapters, concepts, IS_PART_OF, REQUIRES
  2. kg_extended_edges.cypher            — ProblemType, extended edge types
"""

import asyncio
import os
import re
import sys
import time

from dotenv import load_dotenv
from neo4j import AsyncGraphDatabase

load_dotenv()


async def run_cypher_file(driver, file_path: str) -> int:
    """Execute every statement in a .cypher file against Neo4j.

    Splits on semicolons, skips blank/comment-only statements.
    Returns the number of statements executed.
    """
    with open(file_path, "r", encoding="utf-8") as f:
        raw = f.read()

    # Split on semicolons, strip whitespace
    raw_statements = raw.split(";")
    statements = []
    for stmt in raw_statements:
        # Remove // line comments
        cleaned = re.sub(r"//.*", "", stmt).strip()
        if cleaned:
            statements.append(stmt.strip())  # keep original (comments are harmless in Cypher)

    print(f"\n📄 {os.path.basename(file_path)}: {len(statements)} statements to execute")

    executed = 0
    async with driver.session() as session:
        for i, stmt in enumerate(statements, 1):
            try:
                await session.run(stmt)
                executed += 1
                # Progress indicator every 25 statements
                if i % 25 == 0 or i == len(statements):
                    print(f"   ✅ {i}/{len(statements)} done")
            except Exception as e:
                print(f"   ❌ Statement {i} failed: {e}")
                # Print the first 200 chars of the failing statement for debugging
                print(f"      {stmt[:200]}...")

    return executed


async def verify_graph(driver):
    """Run verification queries and print stats."""
    print("\n─── Verification ───")

    async with driver.session() as session:
        # Node counts by label
        result = await session.run(
            "MATCH (n) RETURN labels(n)[0] AS type, count(n) AS cnt ORDER BY type"
        )
        records = await result.data()
        print("\n📊 Node counts:")
        total_nodes = 0
        for r in records:
            print(f"   {r['type']:20s} : {r['cnt']}")
            total_nodes += r['cnt']
        print(f"   {'TOTAL':20s} : {total_nodes}")

        # Edge counts by type
        result = await session.run(
            "MATCH ()-[r]->() RETURN type(r) AS type, count(r) AS cnt ORDER BY cnt DESC"
        )
        records = await result.data()
        print("\n🔗 Edge counts:")
        total_edges = 0
        for r in records:
            print(f"   {r['type']:30s} : {r['cnt']}")
            total_edges += r['cnt']
        print(f"   {'TOTAL':30s} : {total_edges}")


async def main():
    uri = os.getenv("NEO4J_URI")
    user = os.getenv("NEO4J_USER")
    password = os.getenv("NEO4J_PASSWORD")

    print(f"🔌 Connecting to Neo4j at {uri} as {user}...")
    driver = AsyncGraphDatabase.driver(uri, auth=(user, password))

    # Verify connectivity
    try:
        await driver.verify_connectivity()
        print("✅ Connected to Neo4j successfully!\n")
    except Exception as e:
        print(f"❌ Cannot connect to Neo4j: {e}")
        print("   Make sure Neo4j is running and .env credentials are correct.")
        await driver.close()
        sys.exit(1)

    # Locate Cypher files (relative to repo root)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    backend_dir = os.path.dirname(script_dir)
    repo_root = os.path.dirname(backend_dir)

    seed_file = os.path.join(backend_dir, "kg_seed_electrodynamics (1).cypher")
    edges_file = os.path.join(repo_root, "kg_extended_edges.cypher")

    # Check files exist
    for f in [seed_file, edges_file]:
        if not os.path.exists(f):
            print(f"❌ File not found: {f}")
            await driver.close()
            sys.exit(1)

    start = time.time()

    # Step 1: Core seed (chapters, concepts, IS_PART_OF, REQUIRES)
    count1 = await run_cypher_file(driver, seed_file)

    # Step 2: Extended edges (ProblemType, confusion, analogy, etc.)
    count2 = await run_cypher_file(driver, edges_file)

    elapsed = time.time() - start
    print(f"\n⏱️  Executed {count1 + count2} statements in {elapsed:.1f}s")

    # Step 3: Verify
    await verify_graph(driver)

    await driver.close()
    print("\n🎉 Seeding complete! Open http://localhost:7474 to visualize your graph.")


if __name__ == "__main__":
    asyncio.run(main())
