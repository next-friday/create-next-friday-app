# Plan: Loop autonomy, recorded after the build

Accepted by: @joetakara.

The change was built by the `sdlc` plugin before this repository committed a plan for each change. The product owner accepted this record when the open specs were closed, so it lists where each requirement is in the tree.

## Files that change

- `plugins/sdlc/source/skills/sdlc-mode/` (existing): the playbooks carry each step to the next human gate.
- `.agents/rules/agent-owned-work.md` and `templates/base/.agents/rules/agent-owned-work.md` (existing): the human gates, and doing every other step without asking.
- `AGENTS.md` (existing): convention 7 runs work through `/sdlc:sdlc-mode`, and convention 8 puts this repository's playbooks first.

## Order of work

1. Built before this record; the Proof names where.

## Risks

- None open: each requirement is in the tree, as the Proof names.

## Proof

- 1: `plugins/sdlc/source/skills/sdlc-mode/playbooks/design.md` commits the spec and opens its pull request; `open-pr.md` and `review.md` open the pull request and drive it to green.
- 2: `.agents/rules/agent-owned-work.md` lists the human gates and carries a task to the next one without asking.
- 3: the same rule writes a decision no file settles into the artifact as a proposal.
- 4: `AGENTS.md` convention 7 and the stacks' `AGENTS.md` hold the standing request to run work through `/sdlc:sdlc-mode`.
- 5: `playbooks/review.md` never approves or merges, and drives the pull request until only the code owner's approval is left.
- 6: `AGENTS.md` convention 8 puts this repository's skills and playbooks over a skill from another checkout.
