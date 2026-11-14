#!/bin/sh
command -v jq > /dev/null || exit 0
input=$(cat)
project=$(printf '%s' "$input" | jq -r '.cwd // .workspace_roots[0] // ""')
[ -n "$project" ] && cd "$project" 2> /dev/null || exit 0
git rev-parse --is-inside-work-tree > /dev/null 2>&1 || exit 0
jq -e '.scripts.verify' package.json > /dev/null 2>&1 || exit 0

if [ "$1" = followup ]; then
  [ "$(printf '%s' "$input" | jq -r '"\(.status // "") \(.loop_count // "")"')" = 'completed 0' ] || exit 0
fi

state="${TMPDIR:-/tmp}/sdlc-verify"
mkdir -p "$state"
key=$(pwd | cksum | cut -d ' ' -f 1)
changes=$(git status --porcelain --untracked-files=all -- . ':(exclude)intent')
fingerprint=$({
  git rev-parse HEAD 2> /dev/null
  printf '%s\n' "$changes"
  git diff HEAD -- . ':(exclude)intent' 2> /dev/null
} | cksum | cut -d ' ' -f 1)
last=$(cat "$state/$key" 2> /dev/null)

if [ "$last" = "$fingerprint" ]; then
  exit 0
fi

if [ -z "$last" ] && [ -z "$changes" ]; then
  printf '%s' "$fingerprint" > "$state/$key"
  exit 0
fi

if output=$(pnpm verify 2>&1); then
  printf '%s' "$fingerprint" > "$state/$key"
  exit 0
fi

reason="pnpm verify failed on the files this turn changed. Fix the code, not the check, and run it again. Its last lines:
$(printf '%s\n' "$output" | tail -n 30)"

if [ "$1" = followup ]; then
  jq -n --arg message "$reason" '{followup_message: $message}'
else
  jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
fi
