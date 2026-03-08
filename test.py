import asyncio
from typing import Annotated
from semantic_kernel import Kernel
from semantic_kernel.connectors.ai.open_ai import AzureChatCompletion, AzureChatPromptExecutionSettings
from semantic_kernel.functions import kernel_function

# 1. Define the Plugin
class StudentProgressPlugin:
    @kernel_function(
        name="get_weak_concepts",
        description="Returns a list of physics concepts a student is struggling with."
    )
    def get_weak_concepts(
        self, 
        student_id: Annotated[str, "The unique identifier for the student"]
    ) -> str:
        # Hardcoded for Step 1 validation
        return "capacitors_series, kirchhoffs_laws"

async def main():
    # 2. Initialize the Kernel
    kernel = Kernel()

    # 3. Add Azure OpenAI Service
    # Parameters are pulled from env vars automatically if not provided here
    chat_service = AzureChatCompletion(service_id="chat_completion")
    kernel.add_service(chat_service)

    # 4. Register the Plugin
    kernel.add_plugin(StudentProgressPlugin(), plugin_name="student_tracker")

    # 5. Configure Tool Calling (Critical Step)
    # We must explicitly enable function calling in the execution settings
    execution_settings = AzureChatPromptExecutionSettings(service_id="chat_completion")
    execution_settings.tool_choice = "auto"
    execution_settings.function_call_behavior = "auto" # Set to 'auto' for dynamic invocation

    # 6. Test the Loop
    user_input = "Which concepts should student 'STU_123' focus on today?"
    
    # We use kernel.invoke_prompt to allow the LLM to 'think' and use the tool
    result = await kernel.invoke_prompt(
        prompt=user_input,
        settings=execution_settings
    )

    print(f"User: {user_input}")
    print(f"Agent: {result}")

if __name__ == "__main__":
    asyncio.run(main())