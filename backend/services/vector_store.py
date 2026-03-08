"""Prisma AI — Vector store for semantic question retrieval.

Locally: FAISS index + Ollama embeddings.
Azure (later): Azure AI Search — only this file changes.

The FAISS index is in-memory only. It rebuilds from Postgres
on every app startup via load_from_postgres().
"""

import logging
import os
from typing import List

import httpx
import numpy as np

from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

VECTOR_PROVIDER = os.getenv("VECTOR_PROVIDER", "local")
EMBEDDING_MODEL = os.getenv("OLLAMA_EMBED_MODEL", "nomic-embed-text")
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
EMBEDDING_DIM = 768


class VectorStore:
    """Semantic similarity search over the question bank."""

    def __init__(self):
        if VECTOR_PROVIDER == "local":
            import faiss

            self.index = faiss.IndexFlatL2(EMBEDDING_DIM)
            self.stored_ids: List[str] = []

    # ------------------------------------------------------------------
    # Embed
    # ------------------------------------------------------------------
    async def embed(self, text: str) -> List[float]:
        """Get embedding vector from Ollama.

        Raises:
            RuntimeError: If Ollama is unreachable or returns an error.
        """
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                resp = await client.post(
                    f"{OLLAMA_URL}/api/embeddings",
                    json={"model": EMBEDDING_MODEL, "prompt": text},
                )
                resp.raise_for_status()
                return resp.json()["embedding"]
        except httpx.ConnectError:
            raise RuntimeError(
                f"Cannot connect to Ollama at {OLLAMA_URL}. "
                f"Make sure Ollama is running and the model "
                f"'{EMBEDDING_MODEL}' is pulled."
            )
        except (httpx.HTTPStatusError, KeyError) as e:
            raise RuntimeError(
                f"Ollama embedding request failed: {e}"
            )

    # ------------------------------------------------------------------
    # Add question
    # ------------------------------------------------------------------
    async def add_question(self, question_id: str, commentary: str) -> None:
        """Embed commentary and add to the FAISS index."""
        if VECTOR_PROVIDER == "local":
            embedding = await self.embed(commentary)
            vector = np.array([embedding], dtype=np.float32)
            self.index.add(vector)
            self.stored_ids.append(question_id)

    # ------------------------------------------------------------------
    # Search
    # ------------------------------------------------------------------
    async def search(self, query: str, top_k: int = 5) -> List[str]:
        """Return the top_k most similar question IDs."""
        if VECTOR_PROVIDER == "local":
            if self.index.ntotal == 0:
                return []

            embedding = await self.embed(query)
            query_vector = np.array([embedding], dtype=np.float32)
            _, indices = self.index.search(query_vector, min(top_k, self.index.ntotal))

            result = []
            for idx in indices[0]:
                if 0 <= idx < len(self.stored_ids):
                    qid = self.stored_ids[idx]
                    if qid:
                        result.append(qid)
            return result

        return []

    # ------------------------------------------------------------------
    # Load from Postgres
    # ------------------------------------------------------------------
    async def load_from_postgres(self, pool) -> None:
        """Rebuild the in-memory FAISS index from the questions table.

        Call once at app startup.
        """
        rows = await pool.fetch("SELECT id, commentary FROM questions")
        count = 0
        for row in rows:
            await self.add_question(row["id"], row["commentary"])
            count += 1
        logger.info("VectorStore loaded %d questions from Postgres", count)
