## Repository Locations

Git repositories live in `$HOME/workspace`, one directory per repo.

`$HOME/workspace/dotfiles` holds the tracked copy of this config. It syncs by
copy, not symlink: `install.sh` writes the repo out to `~/.claude`, and
`update.sh` copies `~/.claude` back into the repo. Edits to `~/.claude` are
untracked until `update.sh` runs. This file is stored there as
`claude/instructions.md`.

### Syncing back to the dotfiles repo

The repo is public. When asked to commit changes to `~/.claude`:

1. Review everything `update.sh` copies for content that should not be
   public: internal hostnames, wiki or ticket links, ticket IDs, email
   addresses, credentials, and descriptions of internal tooling or auth
   setup. Report what you find and let me decide rather than editing it out.
2. Run `update.sh` from the repo root.
3. Read `git status` and `git diff` before committing. The script copies
   whatever is currently on disk, so unrelated local edits ride along. Name
   them.
4. Ask before pushing to origin.

## GitHub Actions Security

When editing GitHub Actions workflow files (`.github/workflows/*.yml`):
- Always include `persist-credentials: false` in every `actions/checkout` step
- Apply this to all jobs, not just specific ones
- When a third-party action is pinned to a SHA (e.g. `owner/action@abc1234 # v1.2.3`),
  verify that the SHA actually corresponds to the version in the comment — look up the
  action's tags/releases to confirm they match before accepting or making changes

## Prose Is Skill-Gated

Invoke the `prose` skill before drafting any prose meant for a human reader:

- code comments and docstrings
- commit messages
- PR titles, descriptions, review comments, and replies to review comments
- JIRA and GitHub issue titles and descriptions
- README and other documentation, user-facing error messages

Invoke it before the first word is written, not as a cleanup pass afterward.
When a more specific skill covers the format (`docstrings`, `pr-description`,
`jira-ticket`, `github-issue`, `pr-review-response`), invoke that one; it pulls
in `prose` itself.

Default to less. Pick the shortest form that carries the information, and cut
any sentence you are unsure earns its place.
