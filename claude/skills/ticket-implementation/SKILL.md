---
name: ticket-implementation
description: Use when starting work on a JIRA ticket or GitHub issue that's been pasted into the conversation, before writing any code for it.
---

# Ticket Implementation

## Overview

A router for working a pasted ticket: reproduce bugs before fixing them,
use or build a plan before implementing, and stay scoped to the ticket
rather than drive-by fixing whatever else turns up. It delegates to
existing skills for the mechanics rather than reimplementing them.

## Workflow

1. **Take the pasted ticket.** One paste is enough — no separate
   type-selection step. Determine which system it's from by its markup
   and identifiers: `{{...}}` inline markup, `h2.`/`h3.` headers, or a
   `PROJ-123`-style key indicate JIRA; plain markdown (`##` headers,
   backtick code), a `#123` reference, or a `github.com/.../issues/` URL
   indicate GitHub. This determines which skill governs any offshoot
   ticket in step 5. Also determine bug vs. feature/task from the
   content — title, labels, an issue-type field, or which template was
   used. Ask only if either determination is genuinely ambiguous.
2. **Bug path — reproduce first.** Write a test that reproduces the bug
   and confirms it fails, before any other work. **REQUIRED SUB-SKILL:**
   `test-driven-development` governs the RED-GREEN-REFACTOR cycle from
   here on, for both the bug and feature paths.
3. **Resolve the plan.**
   - The ticket body contains a `gist.github.com` link: read it, treat
     it as the implementation plan. Update it as understanding evolves
     during the work — explicit confirmation before each `gh gist edit`,
     since editing a gist publishes content.
   - No gist link: **REQUIRED SUB-SKILL:** `writing-plans` to produce
     one.
4. **Implement.** **REQUIRED SUB-SKILL:** `executing-plans` (or
   `subagent-driven-development` if the target is a git repo) to work
   the plan, with `test-driven-development` governing how each piece of
   code gets written. Where the work adds or edits a docstring,
   **REQUIRED SUB-SKILL:** `docstrings` governs it. For any other prose
   produced along the way (commit messages, code comments, status
   updates) not covered by a more specific skill, **REQUIRED
   SUB-SKILL:** `prose` governs it directly.
5. **Scope discipline.** If something unrelated to the ticket surfaces,
   don't fix it. Flag it and offer to draft a ticket for it, using
   `jira-ticket` or `github-issue` to match the current ticket's system.
   Keep working the original ticket regardless of the answer.
6. **Wrap up.** If the work concludes with a pull request, **REQUIRED
   SUB-SKILL:** `pr-description` governs writing it.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Fixing a bug before writing a failing reproduction test | Reproduce first, always |
| Starting to code before resolving a plan (gist or `writing-plans`) | Resolve the plan first |
| Fixing an unrelated issue found mid-work | Flag it, offer a ticket, keep scope |
| Editing a linked gist without confirming first | Show the update, get confirmation, then edit |
| Re-explaining a sub-skill's process inline instead of invoking it | Invoke the sub-skill; don't duplicate its process here |
