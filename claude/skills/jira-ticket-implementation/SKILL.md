---
name: jira-ticket-implementation
description: Use when starting work on a JIRA ticket, before writing any code for it.
---

# JIRA Ticket Implementation

**REQUIRED SUB-SKILL:** Use the `ticket-implementation` skill for the
shared workflow (reproduce, plan, implement, scope discipline, wrap up)
once this skill resolves the ticket's details below.

## Overview

There's no JIRA CLI/API configured here, so nothing gets fetched
automatically the way `gh` fetches a GitHub issue. The key can come from
the branch; the title and description are always explicit input.

## Resolving the ticket

1. **Key.** Read the current branch: `git rev-parse --abbrev-ref HEAD`.
   If the branch name contains a JIRA key (`[A-Z][A-Z0-9]+-[0-9]+`, e.g.
   `PYTHON-1234-fix-parser`), that is the key — say which key you took
   and from which branch, and don't ask for one. A key the user stated
   explicitly wins over the branch. Ask only when neither supplies one.
2. **Title and description.** Ask for whichever is missing. The branch
   supplies the key alone — never a title or description, and a branch
   slug is not a title.
3. **Determine bug vs. feature/task** from the title and description —
   labels, an issue-type field, or which template was used, if
   mentioned. Ask only if genuinely ambiguous.
4. Hand off to `ticket-implementation` with the system set to JIRA (so
   its scope-discipline step offers a `jira-ticket` draft for anything
   unrelated found), plus the resolved type, title, and description.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Asking for the key when the branch name already contains one | Check `git rev-parse --abbrev-ref HEAD` first; use the key it gives |
| Treating a branch-supplied key as the whole ticket | It's the key only — still ask for title and description |
| Turning the branch slug into a title (`fix-parser` → "Fix parser") | Ask for the real title; a slug is not a title |
| Proceeding with only the key, or only title/description | Ask for whichever of the three is missing |
| Trying to fetch the ticket via an API/CLI | No JIRA integration here — the branch or the user supplies the inputs |
| Guessing bug vs. feature without checking the title/description | Check them first; ask only if still ambiguous |
