"""Convert pinned weights once on Windows; WSL inference needs no Torch install."""
import json
import logging
import os
from pathlib import Path
from filelock import FileLock
from common import STATE, atomic_text, config

logging.basicConfig(level=logging.INFO)
settings = config()
record = json.loads((STATE / 'model.json').read_text())
if record['revision'] != settings['revision']:
    raise SystemExit('Run native Windows step03-download-model first to obtain the configured revision.')
with FileLock(str(STATE / 'ct2-conversion.lock'), timeout=0):
    from crisperwhisper.converter import ensure_ct2_model
    source = Path(record['path'])
    # A relative snapshot name keeps upstream cache names below Windows path limits.
    os.chdir(source.parent)
    path = ensure_ct2_model(source.name, quantization=settings['compute_type'], cache_dir=STATE / 'ct2-export')
    atomic_text(STATE / 'ct2-export.json', json.dumps({**record, 'compute_type': settings['compute_type'], 'path': str(path)}, indent=2)+'\n')
    print('Exported for WSL:', path)
