---
name: jira-ticket
description: Use when drafting a JIRA ticket for a bug, feature, or task, before or while writing the ticket body.
---

# JIRA Ticket

**REQUIRED SUB-SKILL:** Use the `issue` skill first (which itself uses
`prose`), then apply the rules below.

## Overview

This skill supplies JIRA's template-resolution rule and JIRA-specific
markup for the `issue` skill's workflow.

## Template resolution

Ask, every time: "Use the default template, or provide a different one
for this ticket?"
- Default: read `default-template.txt` in this skill's directory. If
  it's still just the placeholder comment, say so and ask for a
  template to use for this ticket instead.
- Different: ask for the template text (JIRA wiki markup).

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
| Assuming the default template without asking | Always ask template choice first |
