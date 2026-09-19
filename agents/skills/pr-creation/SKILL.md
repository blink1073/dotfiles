---
name: pr-creation
description: Use when creating a GitHub pull request via gh pr create, before running the command.
---

# PR Creation

**REQUIRED SUB-SKILL:** Use the `pr-description` skill for the PR
title/body content.

## Overview

Handles the mechanics of opening a PR correctly: pre-flight checks, the
actual default branch (not an assumed `main`), pushing if needed, and
always starting as a draft.

## Workflow

1. **Pre-flight checks.** If `justfile` or `Justfile` exists in the
   repo root, run `just lint` then `just typing`.
   - Recipe doesn't exist (`just`'s stderr contains "Justfile does not
     contain recipe"): skip that check, not a failure.
   - `just lint` fails: **REQUIRED SUB-SKILL:** `just-lint-retry`
     governs handling the failure.
   - `just typing` fails: no retry — a type error isn't auto-fixed by
     re-running the check. Stop here and report it.
   - No justfile: skip pre-flight checks entirely.
   - If pre-flight checks modified any files, commit those changes
     before continuing.
2. **Get the PR content.** **REQUIRED SUB-SKILL:** `pr-description`
   produces the title and body.
3. **Resolve branch details.**
   - Default branch: `gh repo view --json defaultBranchRef -q
     .defaultBranchRef.name`.
   - Current branch: `git branch --show-current`.
   - Owner for `--head`: the fork/origin owner (`gh repo view --json
     owner -q .owner.login`, or the relevant fork's owner if working
     from one).
4. **Push if needed.** If the current branch has no upstream, push it
   (`git push -u origin <branch>`) — confirm first.
5. **Create the PR.** `gh pr create --draft --base <detected-default>
   --head <owner>:<branch> --title <title> --body <description>`.
   `--draft` is always included.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Assuming `--base main` | Detect the actual default branch |
| Treating a missing `just` recipe as a failure | Skip it silently; only a real failure stops the PR |
| Running `just lint`/`just typing` when there's no justfile | Skip pre-flight checks entirely |
| Retrying `just typing` after a failure | Don't — type errors aren't auto-fixed by re-running |
| Creating a PR without `--draft` | Always include it |
| Pushing without confirmation | Confirm before `git push` |
