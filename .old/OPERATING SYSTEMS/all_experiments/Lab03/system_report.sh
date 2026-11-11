#!/usr/bin/env bash
set -u

output=${1-}

make_report() {
  echo "Operating Systems Lab - System Report"
  echo "Generated : $(date)"
  echo "User      : ${USER:-unknown}"
  echo "Host      : $(hostname)"
  echo "Kernel    : $(uname -sr)"
  echo "Working dir: $(pwd)"
  echo
  echo "Disk usage for current filesystem:"
  df -h . | tail -n 1
  echo
  echo "Top five processes by CPU usage:"
  ps -eo pid,ppid,stat,%cpu,comm --sort=-%cpu | head -n 6
}

if [[ -n "$output" ]]; then
  make_report > "$output"
  echo "Report written to $output"
else
  make_report
fi
