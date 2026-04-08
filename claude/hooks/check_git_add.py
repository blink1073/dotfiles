"""Pre-tool hook: reject git add if any explicit files are in .gitignore."""

import json
import shlex
import subprocess
import sys

data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")

try:
    tokens = shlex.split(cmd)
except ValueError:
    sys.exit(0)

# Find 'git' token
try:
    git_idx = next(i for i, t in enumerate(tokens) if t == "git")
except StopIteration:
    sys.exit(0)

if git_idx + 1 >= len(tokens) or tokens[git_idx + 1] != "add":
    sys.exit(0)

add_args = tokens[git_idx + 2 :]

# Reject -f/--force which bypasses .gitignore
if "-f" in add_args or "--force" in add_args:
    print("ERROR: git add -f/--force bypasses .gitignore", file=sys.stderr)
    sys.exit(2)

# Extract explicit file arguments (non-flag tokens after any -- separator)
if "--" in add_args:
    files = add_args[add_args.index("--") + 1 :]
else:
    files = [t for t in add_args if not t.startswith("-")]

if not files:
    sys.exit(0)

result = subprocess.run(
    ["git", "check-ignore", "--verbose"] + files,
    capture_output=True,
    text=True,
)
if result.returncode == 0:
    print(
        "ERROR: The following files are listed in .gitignore and must not be added:\n"
        + result.stdout.strip(),
        file=sys.stderr,
    )
    sys.exit(2)
