"""Course discovery from Typst entry points."""
from dataclasses import dataclass, field
from functools import cached_property
from pathlib import Path
import re
import json
from .typst.reader import evaluate, inline, descendants
from .typst.styles import StyleBook
from .paths import ROOT, LECTURES

@dataclass
class Lecture:
    course: "Course"
    kind: str                       # "chapter" | "lab"
    source: Path
    number: str | None = None       # "1" for Chapter 1 / Lab 1; None for unnumbered chapters
    title: str = ""
    labs: list["Lecture"] = field(default_factory=list)   # labs a chapter leads into

    @property
    def stem(self) -> str:
        return self.source.stem

    @property
    def folder(self) -> str:
        return "chapters" if self.kind == "chapter" else "labs"

    @property
    def rel(self) -> str:
        return f"{self.folder}/{self.stem}"

    @property
    def key(self) -> str:
        return f"{self.course.slug}/{self.rel}"

    @property
    def out_dir(self) -> Path:
        return LECTURES / self.course.slug / self.folder

    @property
    def video(self) -> Path:
        return self.out_dir / f"{self.stem}.mp4"

    @property
    def script_path(self) -> Path:
        return self.out_dir / f"{self.stem}.script.yaml"

    @property
    def voice_dir(self) -> Path:
        return LECTURES / self.course.slug / "voice" / self.folder / self.stem

    @property
    def label(self) -> str:
        if self.kind == "lab":
            return f"Lab {self.number}" if self.number else "Lab"
        return f"Chapter {self.number}" if self.number else "Overview"

    def matches(self, selector: str) -> bool:
        sel = selector.lower().strip()
        m = re.fullmatch(r"(ch|chapter|lab|l)[-_ ]?0*(\d+)", sel)
        if m:
            kind = "lab" if m.group(1) in ("lab", "l") else "chapter"
            return self.kind == kind and (self.number or "").lstrip("0") == m.group(2)
        return sel in (self.stem.lower(), self.rel.lower(), self.source.name.lower())


class Course:
    def __init__(self, folder):
        self.folder = folder
        registry = json.loads((ROOT/'.typst-setup/config/courses.json').read_text())
        self.code = registry[folder.name]['code']
        self.slug = registry[folder.name]['slug']
        self.main_typ = (folder/'main.typ').read_text(encoding='utf-8')
        match = re.search(r'book.with\(title: \[([^\]]+)', self.main_typ)
        self.title = match[1] if match else folder.name.title()
        match = re.search(r'lab-total:\s*(\d+)', self.main_typ)
        self.lab_total = match[1] if match else None
        self.macros = {}
    @cached_property
    def styles(self): return StyleBook()
    @cached_property
    def lectures(self):
        result=[]; chapter=0; parent=None
        for match in re.finditer(r'#include\s+"([^"]+)"', self.main_typ):
            path = ROOT/match[1].lstrip('/') if match[1].startswith('/') else self.folder/match[1]
            if path.parent.name not in ('chapters','labs','appendices') or path.stem=='course-map':continue
            ast = evaluate(path.read_text(encoding='utf-8'))
            lab = next((n['value'] for n in descendants(ast) if n.get('func')=='metadata' and isinstance(n.get('value'),dict) and n['value'].get('utp')=='lab'),None)
            head = next((n for n in descendants(ast) if n.get('func')=='heading'),None)
            if lab:
                lecture=Lecture(self,'lab',path,str(lab['number']),inline(lab['title']))
                if parent:parent.labs.append(lecture)
            elif head:
                numbered=head.get('numbering','auto') is not None
                if numbered:chapter+=1
                lecture=Lecture(self,'chapter',path,str(chapter) if numbered else None,inline(head.get('body',{})))
                parent=lecture
            else:continue
            result.append(lecture)
        return result
    @cached_property
    def labels(self):
        labels={}
        for lecture in self.lectures:
            for label in re.findall(r'<([\w:.-]+)>',lecture.source.read_text(encoding='utf-8')):
                labels[label]=lecture.label if label.startswith(('ch:','sec:lab')) else lecture.title
        return labels

def all_courses():
    return [Course(p.parent) for p in sorted(ROOT.glob('*/main.typ')) if not p.parent.name.startswith('.')]

def find_course(name):
    return next((c for c in all_courses() if name.upper() in (c.code,c.folder.name.upper()) or name.lower()==c.slug),None)
