"""Portable course builds using the official Typst CLI."""
from pathlib import Path
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
SETUP = ROOT / ".typst-setup"

def compiler():
    binary = "typst.exe" if os.name == "nt" else "typst"
    local = SETUP / "bin" / binary
    found = str(local) if local.is_file() else shutil.which("typst")
    if not found:
        raise RuntimeError("Typst is missing. Run step01-install in .typst-setup/windows or .typst-setup/unix.")
    expected = json.loads((SETUP / "config" / "toolchain.json").read_text())["version"]
    actual = subprocess.check_output([found, "--version"], text=True).split()[1]
    if actual != expected:
        raise RuntimeError(f"Expected Typst {expected}, found {actual}. Rerun step01-install in .typst-setup/windows or .typst-setup/unix.")
    return found

# Windows refuses to start a program blocked by Smart App Control or another App Control
# policy with error 4551, and one blocked by AppLocker or a software restriction policy with 1260.
SMART_APP_CONTROL_BLOCK = 4551
POLICY_BLOCKS = {SMART_APP_CONTROL_BLOCK, 1260}
PREVIEW_GUIDE = 'See "Live preview" in .typst-setup/README.md.'

def smart_app_control():
    import winreg
    try:
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SYSTEM\CurrentControlSet\Control\CI\Policy") as key:
            state = winreg.QueryValueEx(key, "VerifiedAndReputablePolicyState")[0]
    except OSError:
        return None  # Windows 10, or a state this account cannot read
    return {0: "Off", 1: "On", 2: "Evaluation"}.get(state)

def tinymist():
    """Newest Tinymist language server installed in VS Code, as (version, path)."""
    roots = [os.environ.get("VSCODE_EXTENSIONS"), Path.home() / ".vscode/extensions", Path.home() / ".vscode-insiders/extensions"]
    found = []
    for root in filter(None, roots):
        for server in Path(root).glob("myriad-dreamin.tinymist-*/out/tinymist.exe"):
            version = re.match(r"myriad-dreamin\.tinymist-(\d+(?:\.\d+)*)", server.parents[1].name)
            if version:
                found.append((tuple(map(int, version[1].split("."))), version[1], server))
    return max(found, default=(None, None, None))[1:]

def check_preview():
    """On Windows, report whether Tinymist, the server behind the VS Code preview, can start."""
    if os.name != "nt":
        return
    state = smart_app_control()
    version, server = tinymist()
    shown = f"; Smart App Control: {state}" if state else ""
    if server is None:
        print(f"Editor preview: Tinymist Typst is not installed in VS Code{shown}")
    else:
        try:
            subprocess.run([str(server), "--version"], capture_output=True, timeout=30, check=True)
        except (OSError, subprocess.SubprocessError) as error:
            code = getattr(error, "winerror", None)
            if code not in POLICY_BLOCKS:
                print(f"WARNING: Tinymist {version} did not start, so the editor preview will not work: {error}")
            elif state == "On" and code == SMART_APP_CONTROL_BLOCK:
                print(f"WARNING: Smart App Control blocks Tinymist {version}, so the editor preview cannot start.")
                print("Turn it off in Windows Security > App & browser control > Smart App Control settings,")
                print("then run Developer: Reload Window in VS Code. Course builds are not affected. " + PREVIEW_GUIDE)
            else:
                print(f"WARNING: A policy on this PC blocks Tinymist {version}, so the editor preview cannot start{shown}.")
                print("Ask the PC's administrator to allow it, or build with step 03 and --watch. " + PREVIEW_GUIDE)
            return
        print(f"Editor preview: Tinymist {version} starts{shown}")
    if state == "On":
        print("Tinymist is unsigned, so Smart App Control can block it after any install or update. " + PREVIEW_GUIDE)
    elif state == "Evaluation":
        print("If Windows switches Smart App Control on, it can block Tinymist and the editor preview. " + PREVIEW_GUIDE)

def courses():
    return sorted(p for p in ROOT.glob("*/main.typ") if not p.parent.name.startswith("."))

def flags():
    return ["--root", str(ROOT), "--font-path", str(ROOT / ".shared/assets/fonts"), "--ignore-system-fonts"]

def select(value):
    path = Path(value)
    if not path.is_absolute():
        path = ROOT / path
    if path.is_dir():
        path /= "main.typ"
    path = path.resolve()
    available = courses()
    if path in available:
        return path
    codes = json.loads((SETUP / "config" / "courses.json").read_text(encoding="utf-8"))
    matches = [p for p in available if value.upper() == codes[p.parent.name]["code"] or value.lower() == codes[p.parent.name]["slug"]]
    if len(matches) == 1:
        return matches[0]
    raise RuntimeError("Select a top-level course folder, main.typ, or course code from courses.json.")

def build(main, watch=False):
    config = json.loads((SETUP / "config/courses.json").read_text(encoding="utf-8"))[main.parent.name]
    output = ROOT / ".all-pdfs" / config["slug"] / (config["code"].upper() + "-Book.pdf")
    output.parent.mkdir(parents=True, exist_ok=True)
    start = time.perf_counter()
    subprocess.run([compiler(), "watch" if watch else "compile", *flags(), str(main), str(output)], check=True)
    print(f"{main.parent.name}: {output} ({time.perf_counter() - start:.2f}s)")
    return output

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("course", nargs="?", help="Course code, folder, or main.typ")
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--watch", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        if args.check:
            print(subprocess.check_output([compiler(), "--version"], text=True).strip())
            print(f"{len(courses())} course entry points; bundled fonts and packages: {ROOT / '.shared'}")
            check_preview()
            return
        if args.watch and args.all:
            parser.error("Use --watch with one course.")
        if not args.all and not args.course:
            parser.error("Choose a course or --all.")
        failed = []
        for source in courses() if args.all else [select(args.course)]:
            try:
                build(source, args.watch)
            except (RuntimeError, subprocess.CalledProcessError) as error:
                print(error, file=sys.stderr)
                failed.append(source)
        if failed:
            raise SystemExit(1)
    except RuntimeError as error:
        parser.exit(1, str(error) + "\n")

if __name__ == "__main__":
    main()
