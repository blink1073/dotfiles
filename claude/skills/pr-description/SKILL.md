---
name: pr-description
description: Use when writing or drafting a pull request description, before or while filling out the PR body.
---

# PR Description

**REQUIRED SUB-SKILL:** Use the `prose` skill first for general writing
rules, then apply the rules below.

## Overview

A PR description tells a reviewer what changed and why they should
approve it. Prose sections carry the *why*; a bullet list carries the
*what*. Don't let a restated diff leak into the prose.

Keep the whole description as short as it can be while still letting a
reviewer approve confidently. Cut anything that doesn't change their
decision.

## Find the template first

Look for, in order: `.github/pull_request_template.md`,
`.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/` (any
file inside). Match case-insensitively.

- **Template exists:** fill it section by section, in its own structure.
  Don't add or remove sections, don't rename them.
- **No template:** use this fallback structure:
  - **Summary** — what and why, 1-2 sentences.
  - **Motivation** — the problem being solved.
  - **Changes** — terse bullet list of what changed.
  - **Testing** — what was actually run. Not "N/A" unless nothing could
    be run — say why.
  - **Breaking changes** — only include this section if there are any;
    omit it rather than writing "None."
  - **AI disclosure** — whether AI generated some or all of the content,
    which tool/model, and confirmation the human author reviewed it and
    ran the code. Always include this section since there's no template
    to omit it from.

## Writing each part

- **Summary/Motivation:** why this change exists, the problem, not the
  diff. If you find yourself listing filenames here, that content
  belongs in Changes instead.
- **Changes:** a flat bullet list, one line per logical change, no
  prose. Describe each change by its outcome or behavior, not its
  implementation — skip parameter names, function signatures, and
  internal identifiers unless a reviewer needs one to find the change.
  "Added a configurable retry limit," not "Added `max_retries` parameter
  to `fetch_page(url, max_retries=3)`."
- **Testing:** the actual command(s) run and their result, not a
  placeholder.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Summary restates the diff ("Changed X.py to add a new function") | Say why the function needed to exist |
| Changes bullet reads like a diff line ("Added `max_retries` param to `fetch_page(url, max_retries=3)`") | Describe the outcome ("Added a configurable retry limit to page fetches") |
| "Testing: N/A" with no explanation | State what was run, or why nothing could be |
| Writing "Breaking changes: None" | Omit the section entirely if there are none |
| Filling a template's sections out of order or renaming them | Match the template's exact structure |
