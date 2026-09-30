#!/usr/bin/env bash
set -u

log=${1:-events.log}
if [[ ! -r "$log" ]]; then
  echo "Cannot read: $log" >&2
  exit 2
fi

echo "Event summary for $log"
for level in INFO WARN ERROR; do
  count=$(grep -c "^$level " "$log" || true)
  printf '%-5s %d\n' "$level" "$count"
done

echo
echo "ERROR lines:"
grep -n '^ERROR ' "$log" || echo "None"
