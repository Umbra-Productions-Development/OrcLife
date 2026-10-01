#!/usr/bin/env bash
# Stop: one line of what is left undone. Context only, never blocks.
set -uo pipefail
in=$(cat)
cwd=$(jq -r '.cwd // empty' <<<"$in"); cd "${cwd:-.}" 2>/dev/null || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$root/.orclife/config.json" ] || exit 0
[ "$(jq -r '.stop_hook_active // false' <<<"$in")" = true ] && exit 0
left=()
orclife gate-fresh || left+=("gate stale")
[ -n "$(git status --porcelain 2>/dev/null)" ] && left+=("uncommitted changes")
[ "$(orclife test-lock status 2>/dev/null)" = unlocked ] && left+=("test-lock still on")
[ ${#left[@]} -gt 0 ] && echo "orclife: before calling this done: ${left[*]}."
exit 0
