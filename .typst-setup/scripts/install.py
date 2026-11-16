"""Install the pinned official Typst release locally; no administrator access needed."""
import hashlib
import json
import platform
import shutil
import tarfile
import tempfile
import urllib.request
import zipfile
import argparse
import subprocess
import sys
from pathlib import Path

SETUP = Path(__file__).resolve().parents[1]

def download(url):
    request = urllib.request.Request(url, headers={"User-Agent": "UTP-Typst-Setup"})
    with urllib.request.urlopen(request, timeout=120) as response:
        return response.read()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--editors', action='store_true', help='Install the recommended VS Code extensions')
    parser.add_argument('--publishing', action='store_true', help='Install the PDF splitter in the active Typst Conda environment')
    options = parser.parse_args()
    version = json.loads((SETUP / "config" / "toolchain.json").read_text())["version"]
    arch = {"amd64": "x86_64", "x86_64": "x86_64", "arm64": "aarch64", "aarch64": "aarch64"}.get(platform.machine().lower())
    target = {"Windows": "pc-windows-msvc", "Darwin": "apple-darwin", "Linux": "unknown-linux-musl"}.get(platform.system())
    if not arch or not target:
        raise SystemExit("Unsupported platform. Install Typst " + version + " from the official release and add it to PATH.")
    name = f"typst-{arch}-{target}"
    archive = name + (".zip" if platform.system() == "Windows" else ".tar.xz")
    release = json.loads(download(f"https://api.github.com/repos/typst/typst/releases/tags/v{version}"))
    asset = next((a for a in release["assets"] if a["name"] == archive), None)
    if asset is None:
        raise SystemExit(f"No official release asset for {archive}.")
    data = download(asset["browser_download_url"])
    digest = asset.get("digest", "")
    if not digest.startswith("sha256:"):
        raise SystemExit("The official release did not provide a SHA-256 digest; installation stopped.")
    if hashlib.sha256(data).hexdigest() != digest.removeprefix("sha256:"):
        raise SystemExit("Official release checksum mismatch; installation stopped.")
    with tempfile.TemporaryDirectory() as temporary:
        work = Path(temporary)
        package = work / archive
        package.write_bytes(data)
        if archive.endswith(".zip"):
            with zipfile.ZipFile(package) as z:
                for member in z.namelist():
                    if not (work / member).resolve().is_relative_to(work.resolve()):
                        raise SystemExit("Unsafe archive member.")
                z.extractall(work)
        else:
            with tarfile.open(package) as t:
                t.extractall(work, filter="data")
        binary = "typst.exe" if platform.system() == "Windows" else "typst"
        destination = SETUP / "bin" / binary
        destination.parent.mkdir(exist_ok=True)
        shutil.copy2(work / name / binary, destination)
        destination.chmod(0o755)
        for license_file in (work / name).glob("LICENSE*"):
            shutil.copy2(license_file, destination.parent / license_file.name)
    print(f"Installed official Typst {version}: {destination}")
    if options.publishing:
        subprocess.run([sys.executable, '-m', 'pip', 'install', '-r', str(SETUP/'config/requirements.txt')], check=True)
    if options.editors:
        editor = shutil.which('code')
        if editor is None:
            raise SystemExit('Compiler installed. Add VS Code to PATH, then rerun with --editors, or install the recommended extensions in VS Code.')
        subprocess.run([editor, '--install-extension', 'myriad-dreamin.tinymist'], check=True)
        # Earlier versions also installed Megamist. Beside Tinymist it recompiles on every
        # keystroke and cannot resolve the books' imports, so point it out if it is still there.
        installed = subprocess.run([editor, '--list-extensions'], capture_output=True, text=True).stdout.lower()
        if 'robertmorelli.megamist-typst' in installed:
            print('Megamist Typst is installed; disable it for this workspace or run:')
            print(f'  "{editor}" --uninstall-extension robertmorelli.megamist-typst')

if __name__ == "__main__":
    main()
