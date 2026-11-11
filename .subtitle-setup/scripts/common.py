"""Workspace-local paths; independent of the caller's working directory."""
import json
import os
import re
from pathlib import Path

SETUP = Path(__file__).resolve().parents[1]
ROOT = SETUP.parent
MEDIA = ROOT / '.courses'
STATE = SETUP / 'runtime'
RUNTIME = Path(os.environ.get('UTP_SUBTITLE_RUNTIME', str(STATE)))
RUNTIME.mkdir(parents=True, exist_ok=True)
STATE.mkdir(exist_ok=True)
os.environ['HF_HOME'] = str(RUNTIME / 'huggingface')
os.environ['HF_HUB_DISABLE_SYMLINKS_WARNING'] = '1'
os.environ['TOKENIZERS_PARALLELISM'] = 'false'
EXTENSIONS = {'.mp4', '.mkv', '.mov', '.avi', '.webm', '.m4v', '.mp3', '.wav', '.m4a', '.flac', '.ogg', '.wma'}


def atomic_text(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + '.tmp')
    temporary.write_text(text, encoding='utf-8')
    os.replace(temporary, path)


def config():
    settings = json.loads((SETUP / 'config/settings.json').read_text(encoding='utf-8'))
    settings['backend'] = os.environ.get('UTP_SUBTITLE_BACKEND', settings['backend'])
    return settings


def discover(folder=''):
    target = (MEDIA / folder).resolve()
    if not target.is_relative_to(MEDIA.resolve()) or not target.exists():
        raise ValueError('Select an existing file/folder inside .courses.')
    def media_files():
        if target.is_file():
            if target.suffix.lower() in EXTENSIONS and not target.is_symlink(): yield target
            return
        pending = [target]
        while pending:
            with os.scandir(pending.pop()) as entries:
                for entry in entries:
                    if entry.is_dir(follow_symlinks=False): pending.append(Path(entry.path))
                    elif Path(entry.name).suffix.lower() in EXTENSIONS and entry.is_file(follow_symlinks=False):
                        yield Path(entry.path)
    def natural_key(path):
        return [(1, int(part)) if part.isdigit() else (0, part.casefold())
                for part in re.split(r'(\d+)', str(path))]
    return sorted(media_files(), key=natural_key)
