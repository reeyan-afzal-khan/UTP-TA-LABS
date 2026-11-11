"""An atomic directory lease shared by Windows and WSL (unlike OS file locks)."""
import json
import os
import platform
from datetime import datetime, timezone


class RunLock:
    def __init__(self, path):
        self.path = path

    def __enter__(self):
        try:
            self.path.mkdir()
        except FileExistsError:
            raise RuntimeError(f'A batch owns {self.path}. If a process was forcibly killed, verify no Windows/WSL batch is running, then remove this active-run directory before retrying.') from None
        try:
            (self.path / 'owner.json').write_text(json.dumps({'pid': os.getpid(), 'platform': platform.platform(), 'started': datetime.now(timezone.utc).isoformat()}, indent=2), encoding='utf-8')
        except BaseException:
            self.path.rmdir()
            raise
        return self

    def __exit__(self, *exc):
        (self.path / 'owner.json').unlink()
        self.path.rmdir()
