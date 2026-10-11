"""What appears on screen while a paragraph is spoken: a few words, not the paragraph.

The voice reads the book's sentences in full; the screen shows, per sentence,
only what helps the eye:

    the terms the author marked      \\term{trees} and \\term{graphs}       -> [trees, graphs]
    the items of a list              organized, related, stored, accessed  -> [organized, related, ...]
    a short sentence, as a headline  "A data structure is not just a container."
    nothing new                      a long sentence without any of the above

In the script, each entry of a scene's `show:` list belongs to one spoken
sentence: a string is a headline, a list is a row of chips, {label, chips} is
a labelled row, and '' keeps whatever is already on screen.
"""

from __future__ import annotations

import html
import re

from .latex.inline import InlineContext, Run, parse_inline, runs_to_markup, runs_to_plain

HEADLINE_WORDS = 13
STOP_LEAD = {"list", "lists", "include", "includes", "including", "give", "gives", "are", "is", "be", "as", "such",
             "like", "the", "a", "an", "of", "about", "how", "that", "which", "with", "into", "from", "called",
             "named", "will", "be", "data", "and", "or", "them", "these", "those", "its", "their", "each", "using",
             "use", "uses", "contains", "contain", "has", "have", "for", "to", "in", "on", "at"}
STOP_TAIL = {"as", "in", "on", "at", "for", "to", "of", "and", "or", "the", "a", "an", "examples", "example",
             "memory", "together", "only"}


def _clean(s: str) -> str:
    s = re.sub(r"\s+", " ", s).strip(" .,:;")
    return s


def _marked_phrases(runs: list[Run]) -> tuple[str, list[str]]:
    """(leading label, phrases the author emphasised)."""
    label = ""
    phrases: list[str] = []
    cur = ""
    started = False
    for k, r in enumerate(runs):
        text = runs_to_plain([r]) if r.math is None else runs_to_plain([r])
        marked = r.math is not None or r.style.bold or r.style.italic or r.style.mono or bool(r.style.color)
        if marked and r.style.bold and re.search(r"[.:]\s*$", text) and len(text.split()) <= 4:
            label = label or _clean(text)            # \textbf{Objective.} run-in heading: a label
            if cur.strip():
                phrases.append(_clean(cur))
            cur = ""
            started = True
            continue
        started = started or bool(text.strip())
        if marked:
            cur += text
        else:
            if cur.strip():
                phrases.append(_clean(cur))
            cur = ""
    if cur.strip():
        phrases.append(_clean(cur))
    out = []
    for p in phrases:
        if p and p.lower() not in (x.lower() for x in out) and len(p.split()) <= 5:
            out.append(p)
    return label, out


def _quoted(plain: str) -> list[str]:
    return [_clean(q) for q in re.findall(r"[“\"]([^”\"]{2,40})[”\"]", plain)]


def _list_items(plain: str) -> tuple[str, list[str]]:
    """'... organized, related, stored, and accessed in memory' -> (prefix, items)."""
    body = plain
    prefix = ""
    if ":" in plain:
        prefix, body = plain.split(":", 1)
    m = None
    for cand in re.finditer(r"([^,;:]+(?:,\s*[^,;:]+){2,})", body):
        if m is None or len(cand.group(1)) > len(m.group(1)):
            m = cand
    if not m:
        return "", []
    parts = [p.strip() for p in m.group(1).split(",")]
    parts = [re.sub(r"^(and|or)\s+", "", p) for p in parts if p]
    if len(parts) < 3:
        return "", []
    inner = [len(p.split()) for p in parts[1:-1]] or [2]
    width = max(1, max(inner))
    if max(inner) > 4:
        return "", []
    first = parts[0].split()
    first = first[-width:]
    while first and first[0].lower() in STOP_LEAD:
        first = first[1:]
    last = []
    for w in parts[-1].split():
        if w.lower() in STOP_TAIL and last:
            break
        last.append(w)
    last = last[:width + 1]
    items = [" ".join(first)] + parts[1:-1] + [" ".join(last)]
    items = [_clean(re.sub(r"^(the|a|an)\s+", "", i, flags=re.I)) for i in items]
    items = [i for i in items if i]
    if len(items) < 3:
        return "", []
    prefix = _clean(prefix)
    if len(prefix.split()) > 5:                        # only a short lead-in before a colon is a label
        prefix = ""
    return prefix, items


def sentence_show(tex: str, ctx: InlineContext, colors: dict, mono: str):
    """The on-screen entry for one sentence of LaTeX."""
    runs = parse_inline(tex, ctx)
    plain = runs_to_plain(runs)
    label, marked = _marked_phrases(runs)
    words = len(re.findall(r"\w+", plain))
    if marked:
        return {"label": label, "chips": marked[:5]} if label else marked[:5]
    quoted = _quoted(plain)
    if len(quoted) >= 2:
        return quoted[:4]
    prefix, items = _list_items(plain)
    if items:
        items = items[:6]
        return {"label": prefix, "chips": items} if prefix else items
    if words <= HEADLINE_WORDS:
        markup = runs_to_markup(runs, colors, mono).rstrip(". ")
        return markup
    return ""


def paragraph_show(sentences: list[str], ctx: InlineContext, colors: dict, mono: str, longest: int = 24) -> list:
    shows = [sentence_show(s, ctx, colors, mono) for s in sentences]
    if not any(shows):
        # nothing short or marked: show the shortest sentence, if it is not too long
        lengths = [len(runs_to_plain(parse_inline(s, ctx)).split()) for s in sentences]
        k = min(range(len(sentences)), key=lambda i: lengths[i])
        if lengths[k] <= longest:
            shows[k] = runs_to_markup(parse_inline(sentences[k], ctx), colors, mono).rstrip(". ")
    return shows


def item_show(tex: str, ctx: InlineContext, colors: dict, mono: str) -> str:
    """A list item on screen: itself when short, else its gist."""
    runs = parse_inline(tex, ctx)
    plain = runs_to_plain(runs)
    if len(plain.split()) <= 16:
        return runs_to_markup(runs, colors, mono).rstrip(".;")
    prefix, items = _list_items(plain)
    if items:
        return html.escape((f"{prefix}: " if prefix else "") + " · ".join(items[:6]), quote=False)
    return runs_to_markup(runs, colors, mono).rstrip(".;")
