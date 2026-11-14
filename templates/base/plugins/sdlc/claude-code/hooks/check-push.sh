#!/bin/sh
command -v jq > /dev/null || exit 0
input=$(cat)

allow() {
  [ "$1" = json ] && printf '%s\n' '{"permission":"allow"}'
  exit 0
}

command=$(printf '%s' "$input" | jq -r '.tool_input.command // .command // ""')
printf '%s' "$command" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push([[:space:]]|$)' || allow "$1"

project=$(printf '%s' "$input" | jq -r '.cwd // .workspace_roots[0] // ""')
[ -n "$project" ] && cd "$project" 2> /dev/null || allow "$1"
git rev-parse --is-inside-work-tree > /dev/null 2>&1 || allow "$1"

problems=""
head=$(git rev-parse HEAD)
reviewed=$(cat "$(git rev-parse --git-path sdlc-review)" 2> /dev/null)
if [ "$reviewed" != "$head" ]; then
  problems="${problems}- Commit $head has no review. Review its diff with a fresh subagent as playbooks/review.md step 2 of the sdlc-mode skill says, fix every Important finding, then write the commit you reviewed to $(git rev-parse --git-path sdlc-review).
"
fi

base=$(git merge-base HEAD origin/HEAD 2> /dev/null || git merge-base HEAD origin/main 2> /dev/null)
if [ -n "$base" ]; then
  plans=$(git diff --name-only "$base" HEAD -- 'intent/*/plan.md')
  if [ "$(printf '%s\n' "$plans" | grep -c .)" = 1 ]; then
    for commit in $(git rev-list "$base..HEAD"); do
      files=$(git diff-tree --no-commit-id --name-only -r "$commit" | grep -v '^intent/')
      git diff-tree --no-commit-id --name-only -r "$commit" | grep -qxF "$plans" && continue
      plan_text=$(git show "$commit:$plans" 2> /dev/null)
      for file in $files; do
        printf '%s' "$plan_text" | grep -qF "$file" && continue
        problems="${problems}- Commit $(git rev-parse --short "$commit") changes $file, which $plans does not name, and does not change $plans. Name the file in the plan in that commit.
"
      done
    done
  fi
fi

[ -z "$problems" ] && allow "$1"
message="The push is blocked:
$problems"
if [ "$1" = json ]; then
  jq -n --arg message "$message" '{permission: "deny", user_message: $message, agent_message: $message}'
else
  jq -n --arg message "$message" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $message}}'
fi
