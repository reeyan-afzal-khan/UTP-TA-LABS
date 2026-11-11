"""Launch the WSL CT2 workflow from Windows, preserving spaced file arguments."""
import os
import subprocess
import sys
from pathlib import Path

SETUP = Path(__file__).resolve().parents[1]
distribution = os.environ.get('UTP_SUBTITLE_DISTRO', 'Ubuntu')
if sys.argv[1:2] == ['download']:
    python = SETUP / '.venv/Scripts/python.exe'
    if not python.exists():
        raise SystemExit('First run windows/step01-install.bat and windows/step03-download-model.bat to prepare the Windows conversion environment.')
    subprocess.run([str(python), '-m', 'pip', 'install', 'ctranslate2==4.6.0'], check=True)
    subprocess.run([str(python), str(SETUP / 'scripts/prepare_ct2.py')], check=True)
script = subprocess.check_output(['wsl.exe', '-d', distribution, '--exec', 'wslpath', '-u', (SETUP / 'wsl/run.sh').as_posix()], text=True).strip()
raise SystemExit(subprocess.call(['wsl.exe', '-d', distribution, '--exec', 'bash', script, *sys.argv[1:]]))
