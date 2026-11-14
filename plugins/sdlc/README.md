# sdlc plugin

The `sdlc` plugin runs the software development loop: a skill that matches a request to a playbook and takes it to the next human gate, a help skill, a verifier subagent, and the default policies.

## What the plugin holds

| Path                          | Holds                                                                                                                                                        |
| :---------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `source/`                     | The skills, the subagent's text, the hook scripts with their case tables, and the scripts behind `plan:check`, `bands:check`, and `loop:measure`.            |
| `adapters/`                   | The render of `source/` for each agent tool, with `agents.json` for each tool's subagent fields and `hooks.json` for its hook. `pnpm plugin:sync` writes it. |
| `adapters/claude-code/evals/` | The eval cases, authored there.                                                                                                                              |

## Hooks

The plugin ships `sdlc-status.sh` as a `SessionStart` hook for Claude Code and a `sessionStart` hook for Cursor. When a session starts, it lists each `intent/<change>/` whose intent and spec are not `Status: done.`, with its stage and who acts next, from the files alone, and prints nothing when there is no such change or no `jq`. Claude Code adds the plain text to the session's context; Cursor gets it as `additional_context` from `sdlc-status.sh json`. `/sdlc:sdlc-status` gives the same summary with each change's pull requests. `pnpm plugin:check` runs the hook against `source/hooks/sdlc-status.cases.json`.

`check-verify.sh` runs as a second `Stop` hook for Claude Code, with a timeout of 900 seconds, and as a `stop` hook for Cursor with `loop_limit` 3. When the files outside `intent/` changed since the last passing run, it runs `pnpm verify` and sends its last 30 lines back to the agent when it fails, so the turn goes on until the checks pass; Claude Code ends the turn itself after eight blocks in a row. It records the state that passed under `${TMPDIR:-/tmp}/sdlc-verify/`, and does nothing outside a Git repository, without `jq`, or when `package.json` has no `verify` script.

`check-push.sh` runs before a shell command, as a `PreToolUse` hook on `Bash` for Claude Code and a `beforeShellExecution` hook for Cursor. It reads only `git push`, and refuses it when the last commit is not the hash in the file `git rev-parse --git-path sdlc-review` names, which `playbooks/open-pr.md` step 4 writes after the review, or when a commit on the branch changes a file that the branch's one `plan.md` does not name without changing that `plan.md`. The file is written by the agent, so the hook makes a skipped review visible rather than impossible; the review's findings on the pull request are the record a code owner reads.

The plugin also ships `check-reply-shape.sh`, a POSIX `sh` script that reads the hook input with `jq`, as a `UserPromptSubmit` and a `Stop` hook for Claude Code and as three hooks for Cursor. It checks only a reply whose first line starts with `**Answer:**`, `**Result:**`, or `**No change:**`, and it blocks that reply once, with a reason that asks for the whole reply again, when the reply:

- names a pull request or an issue by number outside a URL, a fenced block, and a code span that holds more than the bare number;
- does not end with a line that starts with `**Now:**`, unless the reply is a `**No change:**` line alone;
- holds more than one URL on its `**Now:**` line;
- links a list page on its `**Now:**` line: a URL that ends with `/pulls` or `/issues`;
- links, on its `**Now:**` line, a URL that its `**Not yet:**` line names;
- holds more than one `**Not yet:**` line outside a fenced block;
- has no line that starts with `**Checks:**` outside a fenced block, when a file outside `intent/` changed during the turn.

To know what changed during the turn, `check-reply-shape.sh snapshot` runs when the person sends a message. It stores a checksum of the content of every file Git tracks or does not ignore, outside `intent/`, in a file named after the conversation under `${TMPDIR:-/tmp}/sdlc-reply-shape/`. When the agent stops, the script takes the checksum again and compares. It reads the content through a copy of the Git index and a scratch object store, both under that directory and deleted after each run, so staging and committing change nothing, and the project's index and objects are not written. It reads every file that changed since the copy of the index, and every untracked file each time, so a large untracked file that Git does not ignore can take the hook past its ten seconds; the rule then does not apply to that turn. Outside a Git repository, on the first stop with no stored checksum, and when the session's folder moved to another repository, the rule does not apply. Only `intent/` at the repository's root is left out, and the content of a submodule is not read.

Cursor's `stop` hook gets no reply text, so the Cursor adapter runs the script from three hooks in `hooks/hooks.json`:

- `beforeSubmitPrompt` runs `check-reply-shape.sh snapshot`;
- `afterAgentResponse` runs `check-reply-shape.sh save`, which writes the reply text to a file named after the conversation under `${TMPDIR:-/tmp}/sdlc-reply-shape/` and prints nothing;
- `stop` runs `check-reply-shape.sh followup` with `loop_limit` 1. It reads that file and deletes it, and after a completed run with `loop_count` 0 it runs the same checks, and prints a `followup_message` with the same reason, which Cursor sends as the next message. Cursor therefore sends at most one follow-up.

The hook needs `jq` on the `PATH` and does nothing without it. `pnpm plugin:check` runs the hook against the cases in `source/hooks/check-reply-shape.cases.json`.

## Use it in this repository

This repository registers the plugin in `.claude/settings.json` as a local `directory` marketplace named `next-friday-plugins` and enables `sdlc@next-friday-plugins`, so a session here loads it once the folder is trusted.

## Checks

Run each from the repository root. Each one runs its self-tests first and exits 1 on a problem or a self-test failure.

| Command             | Checks                                                                                                                                                                                                                                                                                            |
| :------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `pnpm plan:check`   | Each `intent/<change>/plan.md` against the plan template and its `spec.md`; a branch that changes code with no `plan.md`, except a `dependabot/` or `changeset-release/` branch; and a fix that edits a test the default branch holds, unless the plan says `Test change accepted by: @<handle>.` |
| `pnpm bands:check`  | `bands.yaml` against the rules for control bands.                                                                                                                                                                                                                                                 |
| `pnpm loop:measure` | For each `intent/<change>` folder, the days from intent to spec and the commits after each step.                                                                                                                                                                                                  |
| `pnpm plugin:check` | The adapters against `source/`.                                                                                                                                                                                                                                                                   |

## Eval cases

The cases run with `claude plugin eval`. A case's tag says which command runs it:

| Command                | Cases                | Tools granted                                                                                                                          |
| :--------------------- | :------------------- | :------------------------------------------------------------------------------------------------------------------------------------- |
| `pnpm evals:run`       | tagged `no-shell`    | `Write` and `Edit`.                                                                                                                    |
| `pnpm evals:run:write` | tagged `needs-write` | `Write`, `Edit`, and `Bash`. `claude plugin eval` runs `Bash` only under an OS sandbox, which on Linux needs `bubblewrap` and `socat`. |

A grader that requires no file, commit, or branch passes whatever the skill says unless its case may use the tool it forbids, so each case runs under the command that grants that tool.
