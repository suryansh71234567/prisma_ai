"""
Prisma AI — Step 1: Prove Semantic Kernel can orchestrate Ollama
and automatically invoke a plugin tool.

Run:  python test_sk.py
"""

import asyncio

from semantic_kernel import Kernel
from semantic_kernel.connectors.ai.ollama import OllamaChatCompletion, OllamaChatPromptExecutionSettings
from semantic_kernel.connectors.ai.function_choice_behavior import FunctionChoiceBehavior
from semantic_kernel.contents import ChatHistory
from semantic_kernel.functions import KernelArguments, kernel_function


# ---------------------------------------------------------------------------
# 1.  Plugin with a single tool the LLM should call
# ---------------------------------------------------------------------------
class TestPlugin:
    """Exposes student-profile tools to the Semantic Kernel planner."""

    @kernel_function(
        name="get_student_weak_concepts",
        description=(
            "Retrieves the list of concepts a student is currently weak on. "
            "Call this when you need to know what topics a student needs help with."
        ),
    )
    def get_student_weak_concepts(self, student_id: str) -> str:
        """Return a JSON string of weak concepts for the given student."""
        print(f">>> TOOL WAS CALLED with student_id={student_id}")
        return '{"weak_concepts": ["capacitors_series", "kirchhoffs_laws", "gauss_law"]}'


# ---------------------------------------------------------------------------
# 2.  Main async driver
# ---------------------------------------------------------------------------
async def main() -> None:
    # ── Kernel + Ollama service ───────────────────────────────────────────
    kernel = Kernel()

    chat_service = OllamaChatCompletion(
        service_id="default",
        ai_model_id="llama3.1:8b",
        host="http://localhost:11434",
    )
    kernel.add_service(chat_service)

    # ── Register the plugin ──────────────────────────────────────────────
    kernel.add_plugin(TestPlugin(), plugin_name="student_tools")

    # ── Execution settings with auto function-calling ────────────────────
    settings = OllamaChatPromptExecutionSettings(
        service_id="default",
    )
    settings.function_choice_behavior = FunctionChoiceBehavior.Auto()

    # ── Chat history ─────────────────────────────────────────────────────
    history = ChatHistory()
    history.add_system_message(
        "You are a JEE tutor assistant. When asked about a student's weak topics, "
        "you MUST use the get_student_weak_concepts tool. Never guess — always call the tool."
    )
    history.add_user_message(
        "What concepts is student S001 currently struggling with? Use the tool to find out."
    )

    # ── Invoke the chat completion service directly ──────────────────────
    result = await chat_service.get_chat_message_contents(
        chat_history=history,
        settings=settings,
        kernel=kernel,
        arguments=KernelArguments(student_id="S001"),
    )

    # ── Print the final assistant response ───────────────────────────────
    if result:
        for msg in result:
            print(f"\n🤖 Assistant:\n{msg.content}")
    else:
        print("⚠️  No response received from the model.")


# ---------------------------------------------------------------------------
# 3.  Entry-point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    asyncio.run(main())
