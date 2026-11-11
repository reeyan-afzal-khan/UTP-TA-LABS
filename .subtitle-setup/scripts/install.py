"""Create a private environment and install the CUDA 12.8 PyTorch wheel."""
import os
import subprocess
import sys
import venv
from pathlib import Path

SETUP = Path(__file__).resolve().parents[1]


def main():
    if not (3, 11) <= sys.version_info[:2] <= (3, 13):
        raise SystemExit('Use Python 3.11–3.13 (tested with Python 3.13).')
    environment = SETUP / '.venv'
    python = environment / ('Scripts/python.exe' if os.name == 'nt' else 'bin/python')
    if not python.exists():
        venv.EnvBuilder(with_pip=True).create(environment)
    def pip(*args):
        subprocess.run([str(python), '-m', 'pip', *args], check=True)
    pip('install', '--upgrade', 'pip')
    pip('install', 'torch==2.10.0', '--index-url', 'https://download.pytorch.org/whl/cu128')
    lock = SETUP / 'config/requirements-windows-py313.lock.txt'
    requirements = lock if os.name == 'nt' and sys.version_info[:2] == (3, 13) and lock.exists() else SETUP / 'config/requirements.txt'
    pip('install', '-r', str(requirements))
    pip('check')
    subprocess.run([str(python), str(SETUP / 'scripts/manage.py'), 'check'], check=True)


if __name__ == '__main__':
    main()
