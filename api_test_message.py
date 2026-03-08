"""
Focused test for POST /api/session/message with a long timeout.
Reuses the token and session from a fresh register+start so it is self-contained.
"""
import json, time, urllib.request, urllib.error, sys

BASE    = "http://localhost:8000"
EMAIL   = f"msgtest_{int(time.time())}@prisma.ai"
PASSWORD = "Test1234!"

def req(method, path, body=None, token=None, timeout=180):
    url  = BASE + path
    data = json.dumps(body).encode() if body else None
    hdrs = {"Content-Type": "application/json"}
    if token:
        hdrs["Authorization"] = f"Bearer {token}"
    r = urllib.request.Request(url, data=data, headers=hdrs, method=method)
    try:
        with urllib.request.urlopen(r, timeout=timeout) as resp:
            return resp.status, json.loads(resp.read())
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read())
    except Exception as exc:
        return 0, {"error": str(exc)}

# 1. Register (seeds mastery — can take ~5 s)
print("Registering...")
s, b = req("POST", "/api/auth/register", {"email": EMAIL, "name": "Msg Tester", "password": PASSWORD})
print(f"  register -> HTTP {s}")
token = b.get("token","")

# 2. Start session
print("Starting session...")
s, b = req("POST", "/api/session/start", {"chapter": "electrostatics"}, token)
print(f"  start    -> HTTP {s}  goal={b.get('session_goal','')[:80]}")
session_id = b.get("session_id","")

# 3. Send message (give Ollama up to 3 minutes)
print("Sending message (waiting up to 180 s for Ollama)...")
t0 = time.time()
turn_signal = {
    "response_latency_ms": 5000, "hint_requested": False,
    "answer_changed": False, "consecutive_wrong": 0, "consecutive_correct": 0,
}
s, b = req("POST", "/api/session/message", {
    "session_id": session_id,
    "message": "Can you explain Gauss's Law to me?",
    "turn_signal": turn_signal,
}, token, timeout=180)
elapsed = time.time() - t0
print(f"  message  -> HTTP {s}  ({elapsed:.1f} s)")
if s == 200:
    print(f"  response excerpt: {b.get('response','')[:200]}")
    print("\n[PASS] /message is working")
    sys.exit(0)
else:
    print(f"  error body: {b}")
    print("\n[FAIL] /message failed")
    sys.exit(1)
