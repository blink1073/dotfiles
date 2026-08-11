---
name: jira-ticket
description: Use when drafting a JIRA ticket for a bug, task, feature, or build/CI failure, before or while writing the ticket body.
---

# JIRA Ticket

**REQUIRED SUB-SKILL:** Use the `issue` skill first (which itself uses
`prose`), then apply the rules below.

## Overview

This skill supplies JIRA's template-resolution rule and JIRA-specific
markup for the `issue` skill's workflow. A bug, a task, and a broken
build want different fields, so the template is chosen per ticket rather
than fixed.

## Template resolution

**Check the repository first.** If the ticket's repository is
`drivers-evergreen-tools` or `drivers-github-tools`, use
`drivers-template.txt` and skip the content-based table below — repo
identity overrides what the ticket is about for these two repos.

Otherwise, four templates live in this skill's directory. Pick by what
the ticket is *about*, not by who reports it:

| Template | Use when |
|---|---|
| `task-template.txt` | New work, a change, or an improvement — nothing is broken |
| `bug-template.txt` | Shipped behavior is wrong for a user of the product |
| `build-failure-template.txt` | CI, the build, or the test pipeline is red — tooling, not product behavior |
| `drivers-template.txt` | Repo is `drivers-evergreen-tools` or `drivers-github-tools` (see above) |

1. **Infer** the best match from the conversation (repo check above takes
   priority over this step).
2. **State the recommendation and the signal you used** — one line, e.g.
   "Recommending `build-failure-template`: this is a red CI job, not a
   product defect." or "Recommending `drivers-template`: repo is
   `drivers-github-tools`."
3. **Ask** the user to confirm, pick a different one of the four, or
   supply their own template text (JIRA wiki markup) for this ticket.
4. If the chosen file is empty or still just a placeholder comment, say
   so and ask for template text to use for this ticket instead.

The four files are starter templates — edit them in place to match your
org's conventions.

## Markup

- Wrap package, function, class, and other code-object names in
  `{{...}}` inline — not markdown backticks.
- Use a `{code}...{code}` block only for pasted artifacts (error
  messages, stack traces, config snippets), never to describe the fix.

## Formatting review

Before rendering, check for a blank line before every header — JIRA
renders a header wrong without one. No run-on paragraphs where the
template implies separate fields. No doubled blank lines.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Using markdown backticks (`` `foo` ``) for code names | Use `{{foo}}` |
| Header with no blank line before it | Add the blank line |
| Silently picking a template | State the recommendation and its signal, then ask |
| Listing the three and asking "which one?" with no recommendation | Infer first — an open question is not a recommendation |
| Filing a red CI job under `bug-template` | `bug-template` is for product behavior; a broken pipeline is `build-failure-template` |
| Inferring template from ticket content in `drivers-evergreen-tools`/`drivers-github-tools` | Repo name overrides content — use `drivers-template` |
