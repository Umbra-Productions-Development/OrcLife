#!/usr/bin/env bash
# SessionStart: set this session's identity once, then print context. Stdout becomes session context.
set -uo pipefail
in=$(cat)
cwd=$(jq -r '.cwd // empty' <<<"$in"); cd "${cwd:-.}" 2>/dev/null || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$root/.orca/config.json" ] || exit 0
[ -n "$(jq -r '.agent_id // empty' <<<"$in")" ] && exit 0
export CLAUDE_SESSION_ID; CLAUDE_SESSION_ID=$(jq -r '.session_id // empty' <<<"$in")
orca-lc name --set >/dev/null 2>&1
orca-lc context 2>/dev/null
orca-lc tidy >/dev/null 2>&1
echo "orca-lc rules: load skill 'orca' before starting work in this repo."
exit 0
