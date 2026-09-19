"""Pre-tool hook: reject gh pr create invocations missing --base/--head/--draft."""
import json
import re
import sys

data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")

if not re.search(r"\bgh\s+pr\s+create\b", cmd):
    sys.exit(0)

base_match = re.search(r"--base[= ](\S+)", cmd)
if not base_match:
    print("ERROR: gh pr command is missing --base flag", file=sys.stderr)
    sys.exit(2)

# --base is not checked against the repo's default branch: gh rejects a base
# that doesn't exist, and a base that exists but isn't the default is a valid
# stacked PR.

if "--head" not in cmd:
    print("ERROR: gh pr command is missing --head flag", file=sys.stderr)
    sys.exit(2)

if "--draft" not in cmd:
    print(
        "ERROR: gh pr command must include --draft — all new PRs start as drafts",
        file=sys.stderr,
    )
    sys.exit(2)
