# Spec: Agents cannot skip a workflow step

From `intent/workflow-gates/intent.md`. Status: done.

Written at `main` `619cb88` with the product owner's scope for the starter: a generated project that builds, tests, lints, and runs CI, with the full `sdlc` plugin. The steps of the intent that need a GitHub App for the agent, a merge queue, or a ruleset change are outside that scope and withdrawn; a consumer who wants them opens its own intent.

## Requirements

1. When an agent session ends a turn with files outside `intent/` that changed since the last passing run, a hook of the `sdlc` plugin runs `pnpm verify`, and when it fails, sends its last lines back to the agent instead of letting the turn end, in Claude Code and in Cursor.
2. A fix cannot edit a test the default branch already holds without a person's record: the test-edit gate keys on a `fix/` branch whose test is committed, and `pnpm plan:check` refuses a fix plan's branch that edits such a test unless the plan says `Test change accepted by: @<handle>.`, which a code owner writes. The agent no longer sets or clears a marker.
3. `pnpm plan:check` refuses a branch that changes a file outside `intent/` and adds or changes no `intent/<change>/plan.md`, except a branch that Dependabot or the release workflow opens.
4. The same holds in this repository and in every generated project.

## Design

- `plugins/sdlc/source/hooks/check-verify.sh`: a second `Stop` hook with a timeout of 900 seconds in Claude Code, and a `stop` hook with `loop_limit` 3 in Cursor. It records the state that passed under `${TMPDIR:-/tmp}/sdlc-verify/`.
- `.agents/hooks/agent-test-edit-gate.sh`, root and `templates/base/`: the `.git/bug-fix-in-progress` branch is removed, and each stack's `AGENTS.md` says to make every fix on a `fix/` branch.
- `plugins/sdlc/source/scripts/check-plan.ts`: `findUnplannedChangeProblems` and `findFixTestEditProblems`, with self-tests.

## Policies

- **Brand, compliance, UX:** Do not apply; the change adds no text a customer sees and stores no data about a person.
- **Security:** the hooks read the project's own files and run its own `pnpm verify`; no secret is read or printed.

## Areas of concern

1. No policy. Running `pnpm verify` at the end of a turn costs minutes.
   Decision: it runs only when files outside `intent/` changed since the last passing run.
2. No policy. A fix that must change an old test needs a way through.
   Decision: a code owner writes `Test change accepted by: @<handle>.` in the fix plan. No script can tell who wrote the line; the plan is part of the pull request the code owner approves, which is where the line is checked.
3. No policy. Bots open branches with no plan.
   Decision: `dependabot/` and `changeset-release/` branches are exempt.

## Open questions

None.
