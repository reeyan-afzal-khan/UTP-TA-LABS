"""A lecture video written as Python: what the <name>.py file next to each video uses.

    class Video(Lecture):
        course = "algorithms-data-structures"
        source = "chapters/01-introduction.tex"

        def s01(self):                                  # one method per scene, played in this order
            return title(kicker="Algorithms & Data Structures", label="Chapter 1",
                         title="Introduction to Data Structures",
                         say={"001": "Chapter 1: Introduction to Data Structures."})

        @manim_scene(say=["A stack keeps the last value on top. [show] Pop removes it."])
        def s02(self, v):                               # a scene in plain Manim
            box = Square(1.2, color=v.theme.c("blue"))
            yield [Create(box)]                         # step 1: as the cue starts
            yield [box.animate.shift(UP)]               # step 2: at [show]

    if __name__ == "__main__":
        Video.main()

Scenes
    title, section, guide, prose, bullets, callout, code, table, figure, equation, operations, outro.
    Each takes the scene's content as keyword arguments (exactly the fields of the .script.yaml)
    and say=..., the narration.

Narration (say=)
    A dict {cue id: text} or a list of texts. A cue is one stretch of voice; the scene's next step
    is shown as each cue starts and at every [show] inside its text. Use cue(text, ...) for the
    extras: beats=[a, b] (code: play steps a..b of the running code), lines=[a, b] (highlight code
    lines), quiet=[...] (steps without words), pause=4 (a silent "pause and think" after the cue).
    Cue ids name your own recordings (voice/.../<id>.wav); list items get ids like s02-1.

Plain Manim scenes (@manim_scene)
    The method receives v (v.theme colours and text, v.scene the Manim scene, v.top / v.bottom /
    v.left / v.right / v.center the content area) and yields lists of animations, one per step;
    yield (animations, seconds) to choose a step's length. Everything Manim offers is imported here.
"""

from __future__ import annotations

import argparse
import inspect
import re
import textwrap

from manim import *  # noqa: F401,F403  (plain Manim scenes use it through `from utplectures.kit import *`)

SCENE_NAME = re.compile(r"^s\d+\w*$")


def cue(say: str, **extra) -> dict:
    """One cue with extras: cue("text", beats=[3, 5]), cue("text", lines=[2, 4]), cue("text", pause=4)."""
    return {"say": say, **{k: v for k, v in extra.items() if v is not None}}


def _scene(kind: str, say=None, section: str | None = None, **data) -> dict:
    """section= sets the text of the bar at the top (normally it follows the section cards)."""
    sc = {"type": kind, **{k: v for k, v in data.items() if v is not None}}
    sc["_say"] = say
    if section is not None:
        sc["_header"] = section
    return sc


def title(**kw) -> dict:
    """The opening card: kicker (course), label (Chapter 1), title."""
    return _scene("title", **kw)


def section(**kw) -> dict:
    """A section card: number (1.2), title, level (1 for 1.2, 2 for 1.2.1)."""
    return _scene("section", **kw)


def guide(**kw) -> dict:
    """The chapter guide: before (a sentence), outcomes (a list)."""
    return _scene("guide", **kw)


def prose(**kw) -> dict:
    """Key words for a paragraph: show = one entry per spoken sentence (a headline, a list of chips, or '')."""
    return _scene("prose", **kw)


def bullets(**kw) -> dict:
    """A list: items = [{text, term?, ...}], style = dot | number | term, intro."""
    return _scene("bullets", **kw)


def callout(**kw) -> dict:
    """A book box (key idea, pitfall ...): box (its kind), title, parts."""
    return _scene("callout", **kw)


def code(code: str = "", **kw) -> dict:
    """A listing; C++ runs on screen. code (the listing), language, label, first_line, lead, note."""
    return _scene("code", code=textwrap.dedent(code).strip("\n"), **kw)


def table(**kw) -> dict:
    """A table: columns, header, rows."""
    return _scene("table", **kw)


def figure(**kw) -> dict:
    """A figure from the LaTeX, by its key or label: figure, label, number, title, caption."""
    return _scene("figure", **kw)


def equation(**kw) -> dict:
    """A displayed equation: tex."""
    return _scene("math", **kw)


def operations(**kw) -> dict:
    """Operations demonstrated on an array or a value: items, subject (array | value), intro."""
    return _scene("operations", **kw)


def outro(**kw) -> dict:
    """The closing card: title, label, next."""
    return _scene("outro", **kw)


def manim_scene(say, section: str | None = None):
    """Mark a method as a scene written in plain Manim; say= is its narration (as for any scene)."""
    def mark(fn):
        fn._manim_scene = {"say": say, "header": section}
        return fn
    return mark


class Lecture:
    """A lecture video: subclass it, set course and source, and write one method per scene."""

    course: str = ""        # the course folder's slug or code: "algorithms-data-structures" or "ADS"
    source: str = ""        # the LaTeX it was made from, relative to the course folder

    # ------------------------------------------------------------ the script

    @classmethod
    def scene_methods(cls) -> list[str]:
        names: list[str] = []
        for klass in reversed(cls.__mro__):                   # definition order, subclasses last
            for name, fn in vars(klass).items():
                if SCENE_NAME.match(name) and callable(fn) and name not in names:
                    names.append(name)
        return names

    def scenes(self) -> list[dict]:
        """The video's scenes as the engine reads them (the same shape as a .script.yaml)."""
        out, header = [], ""
        for name in self.scene_methods():
            fn = getattr(self, name)
            spec = getattr(fn, "_manim_scene", None)
            if spec is not None:
                sc = {"type": "custom", "method": name, "_say": spec["say"]}
                if spec.get("header") is not None:
                    sc["_header"] = spec["header"]
            else:
                sc = fn()
                if not sc:
                    continue
                sc = dict(sc)
            sc["id"] = name
            say = sc.pop("_say", None)
            if isinstance(say, str):
                say = [say]
            if isinstance(say, dict):
                cues = [{"id": str(k), **(v if isinstance(v, dict) else {"say": v})} for k, v in say.items()]
            else:
                cues = [{"id": f"{name}-{i + 1}", **(v if isinstance(v, dict) else {"say": v})}
                        for i, v in enumerate(say or [])]
            sc["cues"] = cues
            if sc["type"] == "title":
                header = sc.get("_header", "")
            elif sc["type"] == "section" and int(sc.get("level", 1) or 1) == 1:
                plain = re.sub(r"<[^>]+>", "", str(sc.get("title", ""))).strip()
                header = f"{sc['number']}  {plain}" if sc.get("number") else plain
            if "_header" in sc:
                header = sc.pop("_header")
            sc["section"] = header
            out.append(sc)
        return out

    # ------------------------------------------------------------- running

    @classmethod
    def main(cls, argv: list[str] | None = None) -> None:
        """python <this file> [--draft] [--stills] [--only s05 s06] [--voice tts|auto|recorded]"""
        p = argparse.ArgumentParser(description=f"Render this lecture video ({cls.source}).")
        p.add_argument("--draft", action="store_true", help="quick 540p 30 fps preview, kept in the cache")
        p.add_argument("--stills", action="store_true", help="one still per cue, no video (a layout check)")
        p.add_argument("--only", nargs="+", metavar="SCENE", help="just these scenes (a draft unless --stills)")
        p.add_argument("--voice", choices=["auto", "tts", "recorded"], help="override voice.mode")
        a = p.parse_args(argv)
        from .build import build_from_python
        build_from_python(cls, inspect.getfile(cls), draft=a.draft or bool(a.only and not a.stills),
                          stills=a.stills, only=a.only, voice=a.voice)


class Stage:
    """What a plain-Manim scene gets: the theme, the Manim scene, and the content area."""

    def __init__(self, template):
        from .render.widgets import BODY_BOTTOM, LEFT_X, RIGHT_X
        self.theme = template.theme
        self.scene = getattr(template.ctx, "scene", None)
        self.top, self.bottom = template.top, BODY_BOTTOM
        self.left, self.right = LEFT_X, RIGHT_X
        self.center = [0.0, template.mid_y, 0.0]
        self.cues = template.sc.get("cues", [])
