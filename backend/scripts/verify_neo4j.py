"""Quick verify: print node and edge counts from Neo4j."""
import asyncio, os
from dotenv import load_dotenv
from neo4j import AsyncGraphDatabase

load_dotenv()

async def check():
    d = AsyncGraphDatabase.driver(
        os.getenv("NEO4J_URI"),
        auth=(os.getenv("NEO4J_USER"), os.getenv("NEO4J_PASSWORD"))
    )
    async with d.session() as s:
        r = await s.run("MATCH (n) RETURN labels(n)[0] AS type, count(n) AS cnt ORDER BY type")
        data = await r.data()
        print("=== NODES ===")
        for row in data:
            print(f"  {row['type']:20s}: {row['cnt']}")

        r2 = await s.run("MATCH ()-[r]->() RETURN type(r) AS type, count(r) AS cnt ORDER BY cnt DESC")
        data2 = await r2.data()
        print("\n=== EDGES ===")
        for row in data2:
            print(f"  {row['type']:30s}: {row['cnt']}")
    await d.close()

asyncio.run(check())
