# Spec: Each change is reviewed and kept in step with its plan before it is pushed

From `intent/pre-push-review/intent.md`. Status: done.

Written at `main` `619cb88` with the product owner's scope for the starter: a generated project that builds, tests, lints, and runs CI, with the full `sdlc` plugin.

## Requirements

1. Before every push, a subagent with a fresh context reviews the commit against `REVIEW.md`, `spec.md`, and `plan.md`, and the agent fixes every Important finding first.
2. A hook of the `sdlc` plugin refuses `git push` when the last commit is not the commit the review recorded, in Claude Code and in Cursor.
3. The same hook refuses a push whose commits change a file the branch's `plan.md` does not name, unless that commit also changes `plan.md`.
4. The review's findings are posted on the pull request.
5. Bugbot and CodeRabbit are gone, and the review rules live in `.agents/review.md` alone.
6. The same holds in this repository and in every generated project.

## Design

- `playbooks/open-pr.md` step 4: review before each push, then write the reviewed commit's hash to the file `git rev-parse --git-path sdlc-review` names. Every playbook that pushes follows it: `review.md` step 4, `plan.md` step 6, `design.md` step 4, and `maintain.md` step 5.
- `plugins/sdlc/source/hooks/check-push.sh`: a `PreToolUse` hook on `Bash` in Claude Code and a `beforeShellExecution` hook in Cursor, with cases in `check-push.cases.json`.

## Policies

- **Brand, compliance, UX:** Do not apply.
- **Security:** the hook reads Git only and prints a fixed reason; no secret is read or printed.

## Areas of concern

1. No policy. The agent writes the review record, so a session could write it without a review.
   Decision: accepted. The hook makes a skipped review visible, and the findings on the pull request are what a code owner reads.
2. No policy. A review before every push adds a subagent call to each push.
   Decision: accepted, as the intent asks for a review before every push.

## Open questions

None.
