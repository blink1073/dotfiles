"""Pre-tool hook: reject gh pr create invocations missing --base or --head."""
import json
import re
import sys

data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")

if re.search(r"\bgh\s+pr\s+create\b", cmd):
    if "--base main" not in cmd:
        print("ERROR: gh pr command must use --base main", file=sys.stderr)
        sys.exit(2)
    if "--head" not in cmd:
        print("ERROR: gh pr command is missing --head flag", file=sys.stderr)
        sys.exit(2)
