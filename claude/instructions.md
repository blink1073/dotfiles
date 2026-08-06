## Pull Requests
- Always run `just typing` and `just pre-commit` before making a pull request
- `gh pr create` must always include `--base main` and  `--head owner:branch` flag (e.g., `--head username:branch-name`)
- Get the current branch with `git branch --show-current` and remote with `git remote get-url origin` if needed

## GitHub Actions Security

When editing GitHub Actions workflow files (`.github/workflows/*.yml`):
- Always include `persist-credentials: false` in every `actions/checkout` step
- Apply this to all jobs, not just specific ones
- When a third-party action is pinned to a SHA (e.g. `owner/action@abc1234 # v1.2.3`),
  verify that the SHA actually corresponds to the version in the comment — look up the
  action's tags/releases to confirm they match before accepting or making changes
