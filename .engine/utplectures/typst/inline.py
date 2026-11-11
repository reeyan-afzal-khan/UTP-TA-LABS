"""Canonical inline content for speech, subtitles and Pango display."""
from dataclasses import dataclass, field, replace
import html
import re

@dataclass(frozen=True)
class Style:
    bold: bool = False
    italic: bool = False
    mono: bool = False
    color: str | None = None
    small: bool = False

@dataclass
class Run:
    text: str = ""
    style: Style = field(default_factory=Style)
    math: str | None = None
    newline: bool = False

class InlineContext:
    def __init__(self, labels=None, macros=None, self_label=None):
        self.labels, self.macros, self.self_label = labels or {}, macros or {}, self_label
    def with_self(self, label): return InlineContext(self.labels, self.macros, label)
    def ref(self, label, kind=""):
        return "this figure" if label == self.self_label else self.labels.get(label, label)

def parse_inline(value, ctx=None, style=Style()):
    ctx = ctx or InlineContext()
    runs, pos = [], 0
    pattern = re.compile(r'([*_`$])(.+?)\1|@([\w:.-]+)', re.S)
    for match in pattern.finditer(value):
        runs.append(Run(value[pos:match.start()], style))
        if match[3]: runs.append(Run(ctx.ref(match[3]), style))
        elif match[1] == '$': runs.append(Run(style=style, math=match[2]))
        else:
            key = {'*':'bold', '_':'italic', '`':'mono'}[match[1]]
            runs.append(Run(match[2], replace(style, **{key:True})))
        pos = match.end()
    runs.append(Run(value[pos:], style))
    return runs

def math_to_plain(value):
    return value.replace('\\', '').replace(' thin ', ' ').strip()
def math_to_markup(value): return html.escape(math_to_plain(value))
def math_to_speech(value):
    return math_to_plain(value).replace('^', ' to the power of ').replace('_', ' sub ').replace('/', ' divided by ')
def code_to_speech(value):
    return re.sub(r'([a-z])([A-Z])', r'\1 \2', value).replace('_', ' ').replace('()', '')
def runs_to_plain(runs):
    return re.sub(r'\s+', ' ', ''.join(math_to_plain(r.math) if r.math is not None else r.text for r in runs)).strip()
def runs_to_speech(runs):
    return re.sub(r'\s+', ' ', ''.join(math_to_speech(r.math) if r.math is not None else code_to_speech(r.text) if r.style.mono else r.text for r in runs)).strip()
def runs_to_markup(runs, colors, mono_font):
    out = []
    for run in runs:
        text = math_to_markup(run.math) if run.math is not None else html.escape(run.text)
        if run.style.bold: text = '<b>' + text + '</b>'
        if run.style.italic: text = '<i>' + text + '</i>'
        if run.style.mono: text = '<span font_family="' + html.escape(mono_font) + '">' + text + '</span>'
        out.append(text)
    return ''.join(out)
def convert(value, ctx, colors, mono_font):
    runs = parse_inline(value, ctx)
    return runs_to_markup(runs, colors, mono_font), runs_to_speech(runs), runs_to_plain(runs)
def split_sentences_plain(value): return [s.strip() for s in re.split(r'(?<=[.!?])\s+(?=[A-Z0-9])', value) if s.strip()]
def split_sentences_typst(value): return split_sentences_plain(value)
def count_glyphs(markup): return len(html.unescape(re.sub('<[^>]*>', '', markup)))
