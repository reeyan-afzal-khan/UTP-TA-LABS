"""The UTP logo intro on its own: the ident (the UTP logo and its wordmark, nothing else; about 7 s).

    python .all_lectures/engine/logo_intro.py             -> .all_lectures/utp-logo-intro.mp4 (1080p, 60 fps, ~7 s)
    python .all_lectures/engine/logo_intro.py --title     ... followed by the logo settling beside a chapter title
    python .all_lectures/engine/logo_intro.py --draft     a quick 540p 30 fps version

The animation is utplectures/render/ident.py (its timings are constants at the top of that file:
the logo draws itself, holds OUTRO_HOLD seconds, fades out over OUTRO_FADE, then OUTRO_BLANK of black);
the logo artwork is utplectures/render/brand.py. Every lecture video opens with it, on black.
"""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

ENGINE = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE))
from utplectures.bootstrap import ensure_environment  # noqa: E402

ensure_environment(__file__)


def main() -> None:
    p = argparse.ArgumentParser(description="Render the UTP logo intro on its own.")
    p.add_argument("--title", action="store_true", help="continue into a sample chapter title card")
    p.add_argument("--draft", action="store_true", help="540p 30 fps")
    a = p.parse_args()

    from utplectures.render.worker import _high_quality_encoding
    # near-lossless in the standard High profile (plays everywhere; lossless needs a profile most players
    # lack), with x264's psychovisual tuning off so still edges never flicker from frame to frame
    _high_quality_encoding("2", {"x264-params": "aq-mode=0:psy-rd=0.0,0.0:mbtree=0"})
    from manim import Scene, tempconfig

    from utplectures.config import load_settings
    from utplectures.paths import FONTS, LECTURES, OVERRIDES, cache_dir
    from utplectures.render import ident
    from utplectures.render.brand import logos, split_layers
    from utplectures.render.player import Context, best_antialias
    from utplectures.render.templates import TitleTemplate
    from utplectures.render.text import register_fonts
    from utplectures.render.widgets import Theme

    settings = load_settings()
    register_fonts(FONTS)
    paths = logos()

    class LogoIntro(Scene):
        def construct(self):
            best_antialias()
            theme = Theme.from_settings(settings["theme"], {})
            self.camera.background_color = theme.c("background")
            ctx = Context({"lecture": {}, "paths": {"overrides": str(OVERRIDES), "logos": paths}}, theme)
            ctx.scene = self
            if a.title:
                card = TitleTemplate(ctx, {"kicker": "Algorithms & Data Structures", "label": "Chapter 1",
                                           "title": "Introduction to Data Structures"})
                for anims, seconds in card.preroll():
                    self.play(*anims, run_time=seconds) if anims else self.wait(seconds)
                self.play(*card.step(0), run_time=card.reveal_time)
                self.wait(1.2)
                return
            # the logo alone: it draws itself, holds, then slowly fades away, all in one play (no seams)
            logo = ctx.logo("full", 4.6)
            logo.move_to([0, 0.15, 0])
            phases = ident.steps(logo, paths.get("meta"), split_layers(logo))
            if phases and not phases[-1][0]:
                phases = phases[:-1]                             # the hold before a title: not needed here
            phases = [([], 0.2)] + phases + [([], ident.OUTRO_HOLD),
                                             ([ident.fade_out(theme.c("background"))], ident.OUTRO_FADE),
                                             ([], ident.OUTRO_BLANK)]
            for anims, seconds in ident.as_one_shot(phases):
                self.play(*anims, run_time=seconds)

    work = cache_dir("logo-intro")
    size = (960, 540, 30) if a.draft else (1920, 1080, 60)
    with tempconfig({"pixel_width": size[0], "pixel_height": size[1], "frame_rate": size[2],
                     "media_dir": str(work), "disable_caching": True, "verbosity": "WARNING",
                     "progress_bar": "none", "output_file": "utp-logo-intro"}):
        scene = LogoIntro()
        scene.render()
        movie = Path(scene.renderer.file_writer.movie_file_path)
    dest = LECTURES / "utp-logo-intro.mp4"
    shutil.copyfile(movie, dest)
    print(f"-> {dest}")


if __name__ == "__main__":
    main()
