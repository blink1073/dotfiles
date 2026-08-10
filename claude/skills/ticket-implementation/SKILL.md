---
name: ticket-implementation
description: Use as a base for skills that implement a specific ticket or issue — invoked by jira-ticket-implementation, github-issue-implementation, and similar skills, not directly for a specific tracker.
---

# Ticket Implementation

## Overview

Shared workflow for implementing a ticket once its system, type (bug vs.
feature/task), title, and description are already resolved: reproduce
bugs before fixing them, use or build a plan before implementing, and
stay scoped to the ticket rather than drive-by fixing anything else. It
delegates to existing skills for the mechanics rather than
reimplementing them.

## Workflow

1. **Bug path — reproduce first.** If this is a bug, write a test that
   reproduces it and confirms it fails, before any other work.
   **REQUIRED SUB-SKILL:** `test-driven-development` governs the
   RED-GREEN-REFACTOR cycle from here on, for both the bug and feature
   paths. If you were invoked with no bug/feature determination
   available, ask before proceeding.
2. **Resolve the plan.**
   - The description contains a `gist.github.com` link: read it, treat
     it as the implementation plan. Update it as understanding evolves —
     explicit confirmation before each `gh gist edit`, since editing a
     gist publishes content.
   - No gist link: **REQUIRED SUB-SKILL:** `writing-plans` to produce
     one.
3. **Implement.** **REQUIRED SUB-SKILL:** `executing-plans` (or
   `subagent-driven-development` if the target is a git repo) to work
   the plan, with `test-driven-development` governing how each piece of
   code gets written. Where the work adds or edits a docstring,
   **REQUIRED SUB-SKILL:** `docstrings` governs it. For any other prose
   produced along the way (commit messages, code comments, status
   updates) not covered by a more specific skill, **REQUIRED
   SUB-SKILL:** `prose` governs it directly.
4. **Scope discipline.** If something unrelated to the ticket surfaces,
   don't fix it. Flag it and offer to draft a ticket for it, using
   whichever drafting skill (`jira-ticket` or `github-issue`) matches
   the system you were invoked for. Keep working the original ticket
   regardless of the answer.
5. **Wrap up.** If the work concludes with a pull request, **REQUIRED
   SUB-SKILL:** `pr-creation` governs opening it (which itself uses
   `pr-description` for the content) — don't invoke `pr-description`
   directly and skip `pr-creation`'s mechanics.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Fixing a bug before writing a failing reproduction test | Reproduce first, always |
| Starting to code before resolving a plan (gist or `writing-plans`) | Resolve the plan first |
| Fixing an unrelated issue found mid-work | Flag it, offer a ticket, keep scope |
| Editing a linked gist without confirming first | Show the update, get confirmation, then edit |
| Re-explaining a sub-skill's process inline instead of invoking it | Invoke the sub-skill; don't duplicate its process here |
| Invoking `pr-description` directly to open the PR | Invoke `pr-creation` instead — it handles the description via `pr-description` itself |
