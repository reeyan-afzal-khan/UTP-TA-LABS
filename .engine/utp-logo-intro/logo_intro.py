"""The UTP logo intro on its own: the ident (the UTP logo and its wordmark, nothing else; about 7 s), on white.

    python .engine/utp-logo-intro/logo_intro.py     -> .engine/utp-logo-intro/utp-logo-intro.mp4 (1080p, 60 fps, ~7 s)
    python .engine/utp-logo-intro/logo_intro.py --draft     a quick 540p 30 fps version, kept in the cache

The animation is ident.py (its timings are constants at the top of that file: the logo draws itself,
holds OUTRO_HOLD seconds, fades out over OUTRO_FADE, then OUTRO_BLANK of white); the logo artwork is
brand.py, traced once from logo-UTP.png.
"""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.dont_write_bytecode = True                     # no __pycache__ folder in OneDrive
from render_kit import ensure_environment  # noqa: E402

ensure_environment(__file__)

BACKGROUND = "#FFFFFF"


def main() -> None:
    p = argparse.ArgumentParser(description="Render the UTP logo intro on its own.")
    p.add_argument("--draft", action="store_true", help="540p 30 fps, kept in the cache")
    a = p.parse_args()

    from render_kit import best_antialias, cache_dir, high_quality_encoding
    # near-lossless in the standard High profile (plays everywhere; lossless needs a profile most players
    # lack), with x264's psychovisual tuning off so still edges never flicker from frame to frame
    high_quality_encoding("2", {"x264-params": "aq-mode=0:psy-rd=0.0,0.0:mbtree=0"})
    from manim import Scene, SVGMobject, tempconfig

    import ident
    from brand import logos, split_layers

    paths = logos()
    if not paths.get("full"):
        sys.exit("The UTP logo could not be built (see the message above).")

    class LogoIntro(Scene):
        def construct(self):
            best_antialias()
            self.camera.background_color = BACKGROUND
            # the logo alone: it draws itself, holds, then slowly fades away, all in one play (no seams)
            logo = SVGMobject(paths["full"], stroke_width=0)
            logo.scale_to_fit_height(4.6)
            logo.move_to([0, 0.15, 0])
            phases = ident.steps(logo, paths.get("meta"), split_layers(logo))
            if phases and not phases[-1][0]:
                phases = phases[:-1]                             # the hold before a title: not needed here
            phases = [([], 0.2)] + phases + [([], ident.OUTRO_HOLD),
                                             ([ident.fade_out(BACKGROUND)], ident.OUTRO_FADE),
                                             ([], ident.OUTRO_BLANK)]
            for anims, seconds in ident.as_one_shot(phases):
                self.play(*anims, run_time=seconds)

    work = cache_dir("render")
    size = (960, 540, 30) if a.draft else (1920, 1080, 60)
    with tempconfig({"pixel_width": size[0], "pixel_height": size[1], "frame_rate": size[2],
                     "background_color": BACKGROUND, "media_dir": str(work), "disable_caching": True,
                     "verbosity": "WARNING", "progress_bar": "none", "output_file": "utp-logo-intro"}):
        scene = LogoIntro()
        scene.render()
        movie = Path(scene.renderer.file_writer.movie_file_path)
    if a.draft:
        print(f"-> {movie}")
        return
    dest = HERE / "utp-logo-intro.mp4"
    shutil.copyfile(movie, dest)
    print(f"-> {dest}")


if __name__ == "__main__":
    main()
