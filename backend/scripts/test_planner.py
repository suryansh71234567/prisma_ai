"""Quick test for _extract_json."""
from services.session_planner import _extract_json
import json

# Test 1: clean JSON
r = _extract_json('{"target_concepts": ["ohms_law"]}')
assert r["target_concepts"] == ["ohms_law"]
print("Test 1 OK: clean JSON")

# Test 2: markdown fences
r = _extract_json('```json\n{"max_exchanges": 5}\n```')
assert r["max_exchanges"] == 5
print("Test 2 OK: markdown fences")

# Test 3: surrounding text
r = _extract_json('Here is the plan:\n{"session_goal": "test"}\nDone!')
assert r["session_goal"] == "test"
print("Test 3 OK: surrounding text")

print("All _extract_json tests passed!")
