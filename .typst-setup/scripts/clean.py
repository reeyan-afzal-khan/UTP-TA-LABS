"""Remove disposable build output, keeping sources and published PDFs."""
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[2]

def main():
    target = ROOT / '.build'
    if target.is_symlink() or target.resolve().parent != ROOT.resolve() or target.name != '.build':
        raise SystemExit('Refusing to clean an unexpected or linked path.')
    if target.exists():
        shutil.rmtree(target)
    print('Cleaned .build. Sources, compiler and published PDFs are preserved.')

if __name__ == '__main__':
    main()
