#!/usr/bin/env sh
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SETUP=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
TYPST_ENV="$SETUP/.venv-typst"
TYPST_CONDA=${CONDA_EXE:-}
if [ ! -x "$TYPST_CONDA" ]; then
    TYPST_CONDA=$(command -v conda || true)
fi
if [ -z "$TYPST_CONDA" ]; then
    for base in "$HOME/anaconda3" "$HOME/miniconda3" /opt/anaconda3 /opt/miniconda3 /usr/local/anaconda3 /usr/local/miniconda3; do
        if [ -x "$base/bin/conda" ]; then
            TYPST_CONDA="$base/bin/conda"
            break
        fi
    done
fi
if [ -z "$TYPST_CONDA" ]; then
    echo 'Anaconda was not found. Initialize Conda in this terminal, or set CONDA_EXE to its conda executable.' >&2
    exit 1
fi
if [ "$1" = install.py ] && [ ! -f "$TYPST_ENV/conda-meta/history" ]; then
    if [ -e "$TYPST_ENV" ]; then
        echo "$TYPST_ENV exists but is not a Conda environment. Rename it before running step01 again." >&2
        exit 1
    fi
    "$TYPST_CONDA" create --yes --prefix "$TYPST_ENV" python=3.12 pip
fi
if [ ! -f "$TYPST_ENV/conda-meta/history" ] || [ ! -x "$TYPST_ENV/bin/python" ]; then
    echo "Run step01-install.sh first, or repair the Conda environment at $TYPST_ENV." >&2
    exit 1
fi
script=$1
shift
exec "$TYPST_CONDA" run --no-capture-output --prefix "$TYPST_ENV" "$TYPST_ENV/bin/python" "$SCRIPT_DIR/../scripts/$script" "$@"
