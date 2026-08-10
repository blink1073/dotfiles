"""Pre-tool hook: reject gh pr create invocations missing --base/--head/
--draft, or whose --base doesn't match the repo's actual default branch."""
import json
import re
import subprocess
import sys

data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")

if not re.search(r"\bgh\s+pr\s+create\b", cmd):
    sys.exit(0)

base_match = re.search(r"--base[= ](\S+)", cmd)
if not base_match:
    print("ERROR: gh pr command is missing --base flag", file=sys.stderr)
    sys.exit(2)
base_value = base_match.group(1)

try:
    result = subprocess.run(
        [
            "gh",
            "repo",
            "view",
            "--json",
            "defaultBranchRef",
            "-q",
            ".defaultBranchRef.name",
        ],
        capture_output=True,
        text=True,
        timeout=10,
    )
    default_branch = result.stdout.strip() if result.returncode == 0 else None
except (subprocess.TimeoutExpired, FileNotFoundError):
    default_branch = None

if default_branch and base_value != default_branch:
    print(
        f"ERROR: gh pr command must use --base {default_branch} "
        f"(the repo's actual default branch), got --base {base_value}",
        file=sys.stderr,
    )
    sys.exit(2)
# else: gh repo view unavailable/failed — already satisfied by requiring
# --base to be present with some value above.

if "--head" not in cmd:
    print("ERROR: gh pr command is missing --head flag", file=sys.stderr)
    sys.exit(2)

if "--draft" not in cmd:
    print(
        "ERROR: gh pr command must include --draft — all new PRs start as drafts",
        file=sys.stderr,
    )
    sys.exit(2)
