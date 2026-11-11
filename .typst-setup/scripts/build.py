"""Portable course builds using the official Typst CLI."""
from pathlib import Path
import argparse
import json
import os
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
        raise RuntimeError("Typst is missing. Run: python .typst-setup/scripts/install.py")
    expected = json.loads((SETUP / "config" / "toolchain.json").read_text())["version"]
    actual = subprocess.check_output([found, "--version"], text=True).split()[1]
    if actual != expected:
        raise RuntimeError(f"Expected Typst {expected}, found {actual}. Run .typst-setup/scripts/install.py.")
    return found

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
