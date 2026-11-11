#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SETUP_DIR=$(dirname -- "$SCRIPT_DIR")
export UTP_SUBTITLE_WSL_HOME="${UTP_SUBTITLE_WSL_HOME:-$HOME/.local/share/utp-subtitles}"
export UTP_SUBTITLE_RUNTIME="$UTP_SUBTITLE_WSL_HOME/runtime"
export UTP_SUBTITLE_BACKEND=ct2
export OMP_NUM_THREADS=4
export MKL_NUM_THREADS=4
PYTHON="$UTP_SUBTITLE_WSL_HOME/.venv/bin/python"
ACTION="${1:-check}"
if [ "$#" -gt 0 ]; then shift; fi
if [ "$ACTION" = install ]; then
  exec python3 "$SETUP_DIR/scripts/install_wsl.py" "$@"
fi
if [ ! -x "$PYTHON" ]; then
  echo 'Run the WSL step01 installer first.' >&2
  exit 1
fi
if [ "$ACTION" = transcribe ]; then
  exec "$PYTHON" -u "$SETUP_DIR/scripts/transcribe.py" "$@"
elif [ "$ACTION" = monitor ]; then
  exec /usr/lib/wsl/lib/nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,power.draw --format=csv -l 1
fi
exec "$PYTHON" -u "$SETUP_DIR/scripts/manage.py" "$ACTION" "$@"
