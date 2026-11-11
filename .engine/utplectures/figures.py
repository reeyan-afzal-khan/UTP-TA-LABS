"""Use course-owned SVG/raster assets directly in lecture videos."""
from pathlib import Path
import hashlib
import shutil
import subprocess
import json
from .paths import ROOT
from .typst.reader import toolchain

def figure_key(course, figure):
    return hashlib.sha256((course.slug + str(figure.image) + figure.body + str(figure.caption)).encode()).hexdigest()[:16]

def prepare_figures(course, figures, log=print):
    result = {}
    for figure in figures:
        path = ROOT / figure.image.lstrip('/') if figure.image and figure.image.startswith('/') else course.folder / (figure.image or '')
        key = figure_key(course, figure)
        if path.is_file(): result[key] = {'svg' if path.suffix.lower()=='.svg' else 'image': str(path)}
        else: result[key] = {'error': f'Figure asset not found: {figure.image}'}
    return result

def math_svg(expression, color='#FFFFFF'):
    folder = ROOT / '.build/lecture-math'
    folder.mkdir(parents=True, exist_ok=True)
    key = hashlib.sha256((expression + color).encode()).hexdigest()[:20]
    output = folder / (key + '.svg')
    if not output.exists():
        source = folder / (key + '.typ')
        source.write_text('#set page(width: auto, height: auto, margin: 2pt)\n#set text(size: 24pt, fill: rgb('+json.dumps(color)+'))\n$ '+expression+' $', encoding='utf-8')
        subprocess.run([toolchain.compiler(), 'compile', *toolchain.flags(), str(source), str(output)], check=True, capture_output=True)
    return output

def has_tools():
    missing = [name for name in ('ffmpeg','ffprobe') if shutil.which(name) is None]
    try: toolchain.compiler()
    except RuntimeError: missing.append('typst')
    return missing
