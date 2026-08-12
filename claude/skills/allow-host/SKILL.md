---
name: allow-host
description: Use whenever a spawn host or other disposable remote host needs SSH/SCP access for the rest of a session — invoked by investigating-vulnerability-reports and similar skills, not directly on its own.
---

# Allow Host

## Overview

Once a disposable remote host (spawn host, throwaway VM, container host) is in play, commands over `ssh`/`scp` to it should not require a permission prompt every time. This skill adds a scoped allow rule instead of prompting per command, without opening up `ssh`/`scp` to arbitrary hosts. Claude Code watches `.claude/settings.local.json` and reloads it on change, so the new rule applies immediately — no session restart needed.

## When to use

- A skill or task needs to run repeated `ssh`/`scp` commands against one specific disposable host for the rest of the session
- **Not for:** hosts that aren't disposable/isolated (production, shared infra, anything the user didn't explicitly stand up for this task) — prompt per command there instead

## Process

1. **Get the exact address.** Use the `user@host` the user gave (e.g. `Administrator@ec2-3-85-132-243.compute-1.amazonaws.com`). Don't invent or guess a host.
2. **Add a scoped allow rule** to the repo's `.claude/settings.local.json`, using the colon-prefix wildcard form already used elsewhere in this repo's settings (e.g. `"Bash(just test:*)"`), scoped to that exact `user@host` — never a bare `ssh`/`scp` wildcard covering all hosts:

```json
"permissions": {
  "defaultMode": "auto",
  "allow": ["Bash(ssh user@host:*)", "Bash(scp user@host:*)"]
}
```

3. **Structure every remote command to literally start with** `ssh user@host ...` / `scp user@host:...` (the exact address from step 1, substituted for `user@host` above) so it matches the rule. Never bury the `ssh`/`scp` invocation inside a larger pipeline or wrapper, and never issue an ssh/scp command to a different host than the one the rule was scoped to — that requires its own new rule (or a prompt), not reuse of this one.
4. Note that the local permission check only sees the outer `ssh ...`/`scp ...` invocation, not what runs on the far end. This is only reasonable because the host is disposable and isolated, not because remote commands are individually reviewed.
