# Plan: Each change is reviewed and kept in step with its plan before it is pushed

Accepted by: @joetakara.

## Files that change

- `plugins/sdlc/source/hooks/check-push.sh` and `check-push.cases.json` (new), `plugins/sdlc/adapters/hooks.json` (changed): the push hook.
- `plugins/sdlc/source/skills/sdlc-mode/playbooks/open-pr.md`, `review.md` (changed): the review before each push and its record.
- `plugins/sdlc/README.md` (changed): the hook.

## Order of work

1. The hook and its cases. Check: `pnpm plugin:check` runs them.
2. The playbooks. Check: `pnpm plugin:sync`, then `pnpm plugin:check`.

## Risks

- The record is written by the agent, as the spec's area of concern 1 accepts.

## Proof

- 1: `playbooks/open-pr.md` step 4 and `playbooks/review.md` step 4.
- 2: `check-push.cases.json`: a push with no review is blocked in both tools, a push of the reviewed commit passes, and a command that is not a push passes, including a commit message that names one.
- 3: running the hook on a branch whose commit changes a file the plan does not name blocks the push and names the file.
- 4: `playbooks/open-pr.md` step 6 puts the findings in the review's comment.
- 5: no Bugbot or CodeRabbit file is in the tree.
- 6: the plugin ships in every generated project.
