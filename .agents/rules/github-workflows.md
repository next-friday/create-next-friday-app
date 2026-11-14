# GitHub Workflows

Write a workflow under `.github/` as the Next.js guide does ([`vercel/next.js` `.github/AGENTS.md`](https://github.com/vercel/next.js/blob/canary/.github/AGENTS.md)):

- Trigger on `pull_request`, not `pull_request_target`. The one exception is a workflow that checks out no code, such as `pr-triage.yml`, which labels fork pull requests.
- Set `permissions: {}` at the workflow level, and grant each job only what it needs, with a comment that says why.
- Pin each third-party action to a full commit SHA, with its tag as a trailing comment.
- Pass `persist-credentials: false` to `actions/checkout` unless the job pushes.
- Pass an untrusted value, such as a branch name or a pull request title, through an environment variable, never inside `${{ }}` in a `run:` block. Start a multi-line `run:` block that can fail midway with `set -euo pipefail`.

Record an accepted risk in `.github/zizmor.yml`, as `no-suppression.md` says.
