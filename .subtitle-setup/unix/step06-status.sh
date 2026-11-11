#!/usr/bin/env sh
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$SCRIPT_DIR/../.venv/bin/python" -u "$SCRIPT_DIR/../scripts/manage.py" status "$@"
