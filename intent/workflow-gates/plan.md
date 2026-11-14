# Plan: Agents cannot skip a workflow step

Accepted by: @joetakara.

## Files that change

- `plugins/sdlc/source/hooks/check-verify.sh` and `check-verify.cases.json` (new), `plugins/sdlc/adapters/hooks.json` (changed): the end-of-turn check.
- `scripts/sync-plugin.ts` (changed): a hook may set its timeout and a matcher, two hooks may share an event, and a hook case may write files with their content.
- `plugins/sdlc/source/scripts/check-plan.ts` (changed): the plan rule and the fix test rule.
- `plugins/sdlc/source/skills/sdlc-mode/playbooks/fix.md`, `plugins/sdlc/README.md` (changed): the two rules.
- Each stack's `AGENTS.md` (changed): every fix on a `fix/` branch.
- `.agents/hooks/agent-test-edit-gate.sh`, `scripts/check-agent-gates.ts`, and their copies in `templates/base/` (changed, committed by a person): the marker is removed.

## Order of work

1. The hook and its cases. Check: `pnpm plugin:check` runs them.
2. The two rules and their self-tests. Check: `node plugins/sdlc/source/scripts/check-plan.ts`.
3. The gate's patch. Check: `node scripts/check-agent-gates.ts` and `pnpm verify` in a generated project of each stack, with the patch applied.

## Risks

- A long `pnpm verify` holds the end of a turn; the hook skips a state that already passed.
- The plan rule also applies to this repository's own branches, so every change needs its plan.

## Proof

- 1: `check-verify.cases.json`: a failing verify blocks, a passing one ends the turn, and a Cursor follow-up runs once.
- 2: the self-tests of `findFixTestEditProblems`, and the gate's cases without the marker.
- 3: the self-tests of `findUnplannedChangeProblems`.
- 4: `pnpm verify` in a generated project of each stack with each deploy target.
