---
name: jira-ticket-implementation
description: Use when starting work on a JIRA ticket given its key, title, and description, before writing any code for it.
---

# JIRA Ticket Implementation

**REQUIRED SUB-SKILL:** Use the `ticket-implementation` skill for the
shared workflow (reproduce, plan, implement, scope discipline, wrap up)
once this skill resolves the ticket's details below.

## Overview

Takes a JIRA ticket's key, title, and description as explicit input —
there's no JIRA CLI/API configured here, so nothing gets fetched
automatically the way `gh` fetches a GitHub issue.

## Resolving the ticket

1. **Input:** the ticket key (e.g. `PYTHON-1234`), title, and
   description. Ask for whichever is missing — a key alone isn't
   enough to proceed.
2. **Determine bug vs. feature/task** from the title and description —
   labels, an issue-type field, or which template was used, if
   mentioned. Ask only if genuinely ambiguous.
3. Hand off to `ticket-implementation` with the system set to JIRA (so
   its scope-discipline step offers a `jira-ticket` draft for anything
   unrelated found), plus the resolved type, title, and description.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Proceeding with only the key, or only title/description | Ask for whichever of the three is missing |
| Trying to fetch the ticket via an API/CLI | No JIRA integration here — always ask for the three inputs |
| Guessing bug vs. feature without checking the title/description | Check them first; ask only if still ambiguous |
