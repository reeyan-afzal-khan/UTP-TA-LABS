#!/usr/bin/env bash
set -u

pattern=${1-}
if [[ -z "$pattern" ]]; then
  echo "Usage: $0 PROCESS-NAME" >&2
  exit 2
fi

matches=$(ps -eo pid,ppid,stat,comm | awk -v name="$pattern" 'NR == 1 || $4 ~ name')
count=$(printf '%s\n' "$matches" | tail -n +2 | wc -l)

if (( count == 0 )); then
  echo "No process matched '$pattern'." >&2
  exit 1
fi

printf '%s\n' "$matches"
echo "Matches: $count"
