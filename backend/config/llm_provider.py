"""Prisma AI — LLM provider configuration.

This is the ONLY file in the entire project that knows about LLM providers.
No other file should ever import AzureChatCompletion or OllamaChatCompletion directly.

Kernels:
  build_planner_kernel()    → SessionPlanner LLM
  build_tutor_kernel()      → Tutor LLM (real-time Socratic loop)
  build_summarizer_kernel() → End-of-session summarizer LLM
  build_kernel()            → alias for build_tutor_kernel() (backward compat)
"""

import os

from dotenv import load_dotenv
from semantic_kernel import Kernel
from semantic_kernel.connectors.ai.ollama import OllamaChatCompletion
from semantic_kernel.connectors.ai.open_ai import AzureChatCompletion

load_dotenv()


def _build_kernel_with_deployment(azure_deployment_env: str) -> Kernel:
    """Internal factory — creates a Kernel with the configured LLM service.

    For Ollama: all kernels share the same model (local dev).
    For Azure: each kernel gets a separate deployment via *azure_deployment_env*.
    """
    kernel = Kernel()
    provider = os.getenv("LLM_PROVIDER", "ollama")

    if provider == "azure":
        kernel.add_service(
            AzureChatCompletion(
                deployment_name=os.getenv(azure_deployment_env),
                endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
                api_key=os.getenv("AZURE_OPENAI_KEY"),
                service_id="default",
            )
        )
    elif provider == "ollama":
        kernel.add_service(
            OllamaChatCompletion(
                ai_model_id=os.getenv("OLLAMA_MODEL", "llama3.1:8b"),
                host=os.getenv("OLLAMA_URL", "http://localhost:11434"),
                service_id="default",
            )
        )
    else:
        raise ValueError(
            f"Unknown LLM_PROVIDER: '{provider}'. Must be 'ollama' or 'azure'."
        )

    return kernel


def build_planner_kernel() -> Kernel:
    """Kernel for the SessionPlanner (Azure: AZURE_DEPLOYMENT_PLANNER)."""
    return _build_kernel_with_deployment("AZURE_DEPLOYMENT_PLANNER")


def build_tutor_kernel() -> Kernel:
    """Kernel for the Tutor agent (Azure: AZURE_DEPLOYMENT_TUTOR)."""
    return _build_kernel_with_deployment("AZURE_DEPLOYMENT_TUTOR")


def build_summarizer_kernel() -> Kernel:
    """Kernel for the end-of-session Summarizer (Azure: AZURE_DEPLOYMENT_SUMMARIZER)."""
    return _build_kernel_with_deployment("AZURE_DEPLOYMENT_SUMMARIZER")


def build_kernel() -> Kernel:
    """Backward-compatible alias — returns the tutor kernel."""
    return build_tutor_kernel()
