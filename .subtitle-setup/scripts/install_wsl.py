"""Install a user-local Linux Python 3.12 environment with the CT2 CUDA fork."""
import hashlib
import json
import os
import subprocess
import tarfile
import urllib.request
from pathlib import Path

SETUP = Path(__file__).resolve().parents[1]
BASE = Path(os.environ.get('UTP_SUBTITLE_WSL_HOME', str(Path.home() / '.local/share/utp-subtitles')))


def main():
    if os.name == 'nt': raise SystemExit('Run this installer inside Ubuntu WSL2.')
    BASE.mkdir(parents=True, exist_ok=True)
    tools = BASE / 'tools'
    tools.mkdir(exist_ok=True)
    uv = tools / 'uv-x86_64-unknown-linux-gnu/uv'
    if not uv.exists():
        request = urllib.request.Request('https://api.github.com/repos/astral-sh/uv/releases/tags/0.13.7', headers={'User-Agent': 'UTP-Subtitles'})
        with urllib.request.urlopen(request, timeout=60) as response: release = json.load(response)
        asset = next(a for a in release['assets'] if a['name'] == 'uv-x86_64-unknown-linux-gnu.tar.gz')
        with urllib.request.urlopen(asset['browser_download_url'], timeout=120) as response: data = response.read()
        digest = asset.get('digest', '')
        if not digest.startswith('sha256:') or hashlib.sha256(data).hexdigest() != digest[7:]:
            raise RuntimeError('Official uv asset digest missing or mismatched.')
        archive = tools / asset['name']
        archive.write_bytes(data)
        with tarfile.open(archive) as package: package.extractall(tools, filter='data')
    env = os.environ.copy()
    env['UV_PYTHON_INSTALL_DIR'] = str(BASE / 'python')
    env['UV_CACHE_DIR'] = str(BASE / 'cache/uv')
    def run(*args): subprocess.run([str(uv), *args], check=True, env=env)
    run('python', 'install', '3.12.16')
    python = BASE / '.venv/bin/python'
    if not python.exists(): run('venv', '--python', '3.12.16', str(BASE / '.venv'))
    # The Windows preparation step converts the existing checkpoint once.
    # Linux inference needs the fork's CUDA runtime, not PyTorch.
    requirements = SETUP / 'config/requirements-wsl.lock.txt'
    if not requirements.exists(): requirements = SETUP / 'config/requirements-wsl.txt'
    run('pip', 'install', '--python', str(python), '-r', str(requirements))
    run('pip', 'check', '--python', str(python))
    print('WSL environment ready:', python)


if __name__ == '__main__': main()
