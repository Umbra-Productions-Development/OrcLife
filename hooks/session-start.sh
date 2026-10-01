#!/usr/bin/env bash
# SessionStart: set this session's identity once, then print context. Stdout becomes session context.
set -uo pipefail
in=$(cat)
cwd=$(jq -r '.cwd // empty' <<<"$in"); cd "${cwd:-.}" 2>/dev/null || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$root/.orclife/config.json" ] || exit 0
[ -n "$(jq -r '.agent_id // empty' <<<"$in")" ] && exit 0
export CLAUDE_SESSION_ID; CLAUDE_SESSION_ID=$(jq -r '.session_id // empty' <<<"$in")
orclife name --set >/dev/null 2>&1
orclife context 2>/dev/null
orclife tidy >/dev/null 2>&1
echo "orclife rules: load skill 'orclife' before starting work in this repo."
exit 0
