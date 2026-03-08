"""
Prisma AI — Live HTTP Integration Test
Runs against the uvicorn server at http://localhost:8000

Usage:
    python api_test.py

Each step prints PASS / FAIL with the response body excerpt.
A non-zero exit code means at least one step failed.
"""

import json
import sys
import time
import urllib.request
import urllib.error

BASE = "http://localhost:8000"
PASS = "[PASS]"
FAIL = "[FAIL]"

# Use a unique email so re-runs don't collide with existing rows
EMAIL = f"testuser_{int(time.time())}@prisma.ai"
PASSWORD = "Test1234!"

results = []


def req(method: str, path: str, body: dict | None = None, token: str | None = None):
    url = BASE + path
    data = json.dumps(body).encode() if body else None
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=60) as resp:
            return resp.status, json.loads(resp.read())
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read())
    except Exception as exc:
        return 0, {"error": str(exc)}


def check(step: str, status: int, body: dict, expect_status: int, *required_keys):
    ok = status == expect_status and all(k in body for k in required_keys)
    tag = PASS if ok else FAIL
    results.append(ok)
    excerpt = json.dumps(body)[:300]
    print(f"\n{'='*60}")
    print(f"  {tag}  [{step}]  HTTP {status}")
    print(f"  {excerpt}")
    print(f"{'='*60}")
    return ok


# -- 1. Register ---------------------------------------------------------------
print("\n>> Step 1 -- POST /api/auth/register")
status, body = req("POST", "/api/auth/register", {
    "email": EMAIL,
    "name": "Test Student",
    "password": PASSWORD,
})
ok = check("register", status, body, 201, "token", "student_id", "name")
# FastAPI returns 200 for non-decorated endpoints; accept either
if not ok and status == 200 and "token" in body:
    results[-1] = True
    ok = True
    print("  (200 also acceptable -- marked PASS)")
token = body.get("token", "")
student_id = body.get("student_id", "")


# -- 2. Login ------------------------------------------------------------------
print("\n>> Step 2 -- POST /api/auth/login")
status, body = req("POST", "/api/auth/login", {
    "email": EMAIL,
    "password": PASSWORD,
})
ok = check("login", status, body, 200, "token", "student_id")
if ok:
    token = body["token"]   # refresh with login token


# -- 3. Start session ----------------------------------------------------------
print("\n>> Step 3 -- POST /api/session/start  (may take ~10 s for LLM plan)")
status, body = req("POST", "/api/session/start", {"chapter": "electrostatics"}, token)
ok = check("start", status, body, 200, "session_id", "session_goal")
session_id = body.get("session_id", "")


# -- 4. Send a message ---------------------------------------------------------
print("\n>> Step 4 -- POST /api/session/message  (may take ~15 s for LLM response)")
if session_id:
    turn_signal = {
        "response_latency_ms": 5000,
        "hint_requested": False,
        "answer_changed": False,
        "consecutive_wrong": 0,
        "consecutive_correct": 0,
    }
    status, body = req("POST", "/api/session/message", {
        "session_id": session_id,
        "message": "Can you explain Gauss's Law to me?",
        "turn_signal": turn_signal,
    }, token)
    check("message", status, body, 200, "response", "session_id")
else:
    print(f"\n  {FAIL}  [message]  skipped -- no session_id from step 3")
    results.append(False)


# -- 5. End session ------------------------------------------------------------
print("\n>> Step 5 -- POST /api/session/end  (may take ~15 s for summarizer)")
if session_id:
    status, body = req("POST", "/api/session/end", {
        "session_id": session_id,
    }, token)
    check("end", status, body, 200, "summary", "plan_completion_rate")
else:
    print(f"\n  {FAIL}  [end]  skipped — no session_id from step 3")
    results.append(False)


# ── Summary ───────────────────────────────────────────────────────────────────
passed = sum(results)
total  = len(results)
print(f"\n{'='*60}")
print(f"  Result: {passed}/{total} steps passed")
print(f"{'='*60}\n")

sys.exit(0 if passed == total else 1)
