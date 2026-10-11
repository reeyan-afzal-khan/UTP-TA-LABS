"""The Manim scene that plays a whole lecture from its render plan.

For every scene of the script: transition (fade the old content, update the
header and progress bar), then for every cue: start its audio, reveal steps at
the cue start and at its [show] marks, run the template's own timed events,
and hold until the audio ends. Nothing is timed by hand, so a different voice
(a re-recorded cue, a different TTS speed) re-paces the whole video.
"""

from __future__ import annotations

import json
from pathlib import Path

from manim import (DOWN, LEFT, RIGHT, UP, Arc, Circle, Create, FadeIn, FadeOut, ImageMobject, Rectangle,
                   RoundedRectangle, Scene, SVGMobject, Transform, VGroup, linear)

from .templates import TEMPLATES, load_override
from .widgets import BODY_BOTTOM, LEFT_X, RIGHT_X, Progress, Theme, frame_tag, header, mix


def best_antialias() -> None:
    """Draw every shape with Cairo's best antialiasing (16x16 samples per pixel edge) instead of its
    default: thin gold lines and small type stay smooth, also while they move and scale."""
    import cairo
    from manim.camera.camera import Camera
    if getattr(Camera, "_utp_best", False):
        return
    plain = Camera.get_cairo_context

    def get_cairo_context(self, pixel_array):
        ctx = plain(self, pixel_array)
        ctx.set_antialias(cairo.ANTIALIAS_BEST)
        return ctx
    Camera.get_cairo_context = get_cairo_context
    Camera._utp_best = True


class Context:
    """What templates need from the outside world."""

    def __init__(self, plan: dict, theme: Theme):
        self.plan = plan
        self.theme = theme
        self.lecture = plan["lecture"]
        self.figures = plan.get("figures", {})
        self.overrides = Path(plan["paths"]["overrides"])
        self.logos = plan["paths"].get("logos") or {}

    def figure(self, sc: dict) -> dict:
        return self.figures.get(sc.get("figure") or "", None) or self.figures.get(sc.get("label") or "", {}) or {}

    def override(self, sc: dict):
        label = sc.get("label") or sc.get("figure") or ""
        name = "".join(ch if ch.isalnum() or ch in "-_" else "-" for ch in label)
        return load_override(self.overrides / self.lecture["course"] / f"{name}.py") if name else None

    def logo(self, kind: str, height: float):
        """The UTP logo for black ("full") or its emblem alone ("emblem"): vector art, traced once
        from the repository's logo (brand.py), so it stays sharp and its parts can be animated."""
        path = self.logos.get(kind)
        if not path or not Path(path).exists():
            return None
        if path.endswith(".svg"):
            mob = SVGMobject(path, stroke_width=0)
            mob.scale_to_fit_height(height)
            return mob
        img = ImageMobject(path)
        img.scale_to_fit_height(height)
        return img


class LectureScene(Scene):
    plan: dict = {}

    def construct(self):
        plan = self.plan
        best_antialias()
        self.theme = Theme.from_settings(plan["theme"], plan.get("boxes", {}))
        self.camera.background_color = self.theme.c("background")
        self.ctx = Context(plan, self.theme)
        self.ctx.scene = self                          # for scenes written in plain Manim
        self.pace = plan["pacing"]
        self.fps = plan["video"]["fps"]
        self.timeline: list[dict] = []
        scenes = plan["scenes"]
        self.stills = plan["out"].get("stills")        # layout check: a still per cue, no video

        total = max(1e-6, sum(self._scene_estimate(s) for s in scenes))
        starts, acc = [], 0.0
        for s in scenes:
            starts.append(acc / total)
            acc += self._scene_estimate(s)
        marks = [f for f, s in zip(starts, scenes) if s["type"] == "section" and int(s.get("level", 1) or 1) == 1]

        lec = plan["lecture"]
        self.kicker = f'{lec["course_title"]}  ·  {lec["label"]}'
        self.header = None
        self.header_text = None
        self.progress = Progress(self.theme, marks)
        self.emblem = self.ctx.logo("emblem", 0.62)
        if self.emblem is not None:
            self.emblem.move_to([RIGHT_X - self.emblem.width / 2, 3.52, 0])
        self.tag = None
        self.tag_key = None
        self.chrome_on = False

        self.wait(self.pace.get("lead_in", 0.5))
        for i, sc in enumerate(scenes):
            tmpl = TEMPLATES.get(sc["type"], TEMPLATES["prose"])(self.ctx, sc)
            self._transition(tmpl, sc, starts[i], first=(i == 0))
            for anims, seconds in tmpl.preroll():          # e.g. the logo drawing itself, before the voice
                if anims:
                    self.play(*anims, run_time=seconds)
                else:
                    self.wait(seconds)
            self._run(tmpl, sc)
            print(f"[scene] {i + 1}/{len(scenes)} {sc['type']} done at {self.renderer.time:.1f}s", flush=True)
            if self.stills:
                self._save_frame(Path(self.stills) / f"{sc['id']}-zz-{sc['type']}.png")
        self.wait(self.pace.get("tail", 1.2))
        self.play(*[FadeOut(m) for m in self.mobjects], run_time=0.8)
        Path(plan["out"]["timeline"]).write_text(json.dumps(self.timeline, indent=1), encoding="utf-8")

    # --------------------------------------------------------------- timing

    def _scene_estimate(self, sc: dict) -> float:
        return sum(c["audio"]["duration"] + float(c.get("pause", 0) or 0) + self.pace.get("after_cue", 0.3)
                   for c in sc["cues"]) + self.pace.get("transition", 0.55)

    def now(self) -> float:
        return self.renderer.time

    def wait_until(self, t: float) -> None:
        d = t - self.now()
        if d > 1.0 / self.fps:
            self.wait(d)

    # ----------------------------------------------------------- transitions

    def _transition(self, tmpl, sc: dict, fraction: float, first: bool) -> None:
        anims = []
        keep = {id(m) for m in (self.header, self.progress, self.tag, self.emblem) if m is not None}
        old = [m for m in self.mobjects if id(m) not in keep]
        anims += [FadeOut(m, shift=UP * 0.2) for m in old]
        if tmpl.full_frame:
            # a title or outro card covers everything; the chrome stays underneath
            pass
        else:
            if not self.chrome_on:
                self.header_text = sc.get("section") or ""
                self.header = header(self.theme, self.kicker, self.header_text)
                anims += [FadeIn(self.header, shift=DOWN * 0.1), FadeIn(self.progress)]
                if self.emblem is not None:
                    anims.append(FadeIn(self.emblem))
                self.chrome_on = True
            elif (sc.get("section") or "") != self.header_text:
                self.header_text = sc.get("section") or ""
                new = header(self.theme, self.kicker, self.header_text)
                anims += [FadeOut(self.header, shift=UP * 0.15), FadeIn(new, shift=UP * 0.15)]
                self.header = new
            anims.append(Transform(self.progress.fill, self.progress.at(fraction)))
            key = json.dumps(sc.get("frame"), sort_keys=True) if sc.get("frame") else None
            if key != self.tag_key:
                if self.tag is not None:
                    anims.append(FadeOut(self.tag))
                self.tag = frame_tag(self.theme, sc["frame"]) if sc.get("frame") else None
                if self.tag is not None:
                    anims.append(FadeIn(self.tag, shift=RIGHT * 0.2))
                self.tag_key = key
        if anims and not first:
            self.play(*anims, run_time=self.pace.get("transition", 0.55))
        elif anims:
            self.play(*anims, run_time=0.6)
        if old:
            self.remove(*old)

    # ------------------------------------------------------------------ cues

    def _run(self, tmpl, sc: dict) -> None:
        cues = sc["cues"]
        n_steps = tmpl.n_steps
        marks_total = sum(len(c["audio"].get("marks", [])) for c in cues)
        surplus = 0 if tmpl.manual else max(0, n_steps - (len(cues) + marks_total))
        step = 0
        min_rt = float(self.pace.get("min_reveal", 0.35))
        max_rt = float(self.pace.get("max_reveal", 1.6))
        for ci, cue in enumerate(cues):
            audio = cue["audio"]
            t0 = self.now()
            if not self.stills:
                self.add_sound(audio["path"])
            self.timeline.append({"id": cue["id"], "scene": sc["id"], "start": round(t0, 3),
                                  "duration": audio["duration"], "say": cue.get("display", cue["say"]),
                                  "sentences": audio.get("sentences", []), "words": audio.get("words", []),
                                  "text": audio.get("text", "")})
            events = []
            if not tmpl.manual:
                for _ in range(1 + (surplus if ci == 0 else 0)):
                    if step < n_steps:
                        events.append((0.0, 0, step))
                        step += 1
                for m in audio.get("marks", []):
                    if step < n_steps:
                        events.append((float(m), 0, step))
                        step += 1
            events += [(float(t), 1, fn) for t, fn in tmpl.cue_events(ci, cue)]
            events.sort(key=lambda e: (e[0], e[1]))
            for j, (t, kind, what) in enumerate(events):
                self.wait_until(t0 + t)
                nxt = events[j + 1][0] if j + 1 < len(events) else audio["duration"]
                room = (t0 + nxt) - self.now() - 0.05
                if kind == 0:
                    anims = tmpl.step(what)
                    pref = tmpl.pref_time(what)
                else:
                    anims = what()
                    pref = tmpl.reveal_time
                if not anims:
                    continue
                cap = max_rt * (2 if pref > max_rt else 1)
                rt = max(min_rt, min(pref, cap, room if room > min_rt else min_rt))
                self.play(*anims, run_time=rt)
            self.wait_until(t0 + audio["duration"])
            if self.stills:
                self._save_frame(Path(self.stills) / f"{sc['id']}-{cue['id']}.png")
            if cue.get("pause"):
                self._think(float(cue["pause"]))
            last = ci == len(cues) - 1
            gap = self.pace.get("after_scene", 0.55) if last else self.pace.get("after_cue", 0.3)
            if last and sc["type"] == "section":
                gap += self.pace.get("after_section", 0.4)
            self.wait(gap)
        left = []
        while not tmpl.manual and step < n_steps:
            left += tmpl.step(step)
            step += 1
        left += tmpl.finish()
        if left:
            self.play(*left, run_time=0.5)

    def _think(self, seconds: float) -> None:
        th = self.theme
        label = th.plain("Pause and think", size=22, color="gold", weight="SEMIBOLD")
        ring_bg = Circle(radius=0.2, stroke_color=th.c("faint"), stroke_width=5)
        ring = Arc(radius=0.2, start_angle=1.5708, angle=-6.2831, stroke_color=th.c("gold"), stroke_width=5)
        chip_content = VGroup(VGroup(ring_bg, ring), label).arrange(RIGHT, buff=0.25)
        ring.move_to(ring_bg)
        pill = RoundedRectangle(width=chip_content.width + 0.55, height=chip_content.height + 0.3, corner_radius=0.2,
                                fill_color=th.c("panel"), fill_opacity=1, stroke_color=th.c("gold"), stroke_width=2)
        pill.move_to(chip_content)
        chip = VGroup(pill, chip_content)
        chip.move_to([RIGHT_X - chip.width / 2, BODY_BOTTOM + chip.height / 2 - 0.05, 0])
        self.play(FadeIn(pill), FadeIn(label), FadeIn(ring_bg), run_time=0.35)
        self.play(Create(ring), run_time=max(0.5, seconds - 0.7), rate_func=linear)
        self.play(*[FadeOut(m) for m in (pill, label, ring_bg, ring)], run_time=0.35)

    def _save_frame(self, path: Path) -> None:
        from PIL import Image
        path.parent.mkdir(parents=True, exist_ok=True)
        self.renderer.update_frame(self, ignore_skipping=True)
        Image.fromarray(self.renderer.get_frame()).save(path)
