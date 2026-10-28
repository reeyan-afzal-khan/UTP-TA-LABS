# UTP logo intro

`utp-logo-intro.mp4` is the UTP logo drawing itself on a white background: 1080p, 60 fps, 6.9 s, H.264
High profile. This folder has everything needed to render it again, without the rest of `.engine`.

```text
utp-logo-intro/
  utp-logo-intro.mp4   the video
  logo_intro.py        renders it: python .engine/utp-logo-intro/logo_intro.py
  ident.py             the animation; every timing is a constant at its top
  brand.py             turns logo-UTP.png into clean vector layers (traced once, then cached)
  render_kit.py        picks the right Python, sets up the cache, sharp antialiasing and near-lossless x264
  logo-UTP.png         the source artwork (391 x 761, as printed)
```

## Rendering

```bash
python .engine/utp-logo-intro/logo_intro.py
```

| Run | What it makes |
| --- | --- |
| `python logo_intro.py` | the final video, 1080p 60 fps, written to `utp-logo-intro.mp4` in this folder |
| `python logo_intro.py --draft` | 540p 30 fps, kept in the cache (the path is printed) |

Any Python works: the script re-runs itself under the `utp_lectures` conda environment (see
`.engine/README.md`, Setup). The first run traces the logo, which takes about a minute. After that a
final render takes about 20 s. The traced logo and Manim's frames are kept in
`%LOCALAPPDATA%\utp-lectures\logo-intro-white`. Delete that folder to trace the logo again.

## What happens on screen

1. The oval's outline is drawn from the top in UTP blue, and the blue fills in.
2. Gold flows up the engraved lines from their feet, with a small light riding each flow front.
3. The wordmark tracks in while the gold rules grow from the centre, and a soft light sweeps the emblem.
4. The finished logo holds (`OUTRO_HOLD`), fades to white (`OUTRO_FADE`), and white is held (`OUTRO_BLANK`).

## The colours on white

* Background: `BACKGROUND = "#FFFFFF"` in `logo_intro.py`.
* Oval `#0B4F94` and gold `#E5A21E`, the same as in the lecture engine (`brand.UTP_BLUE`, `brand.UTP_GOLD`).
* Wordmark: `brand.WORD_COLOR = "#034A8C"`, the blue of the printed letters (white text would vanish on
  white). Its hex must stay different from `UTP_BLUE`, because `split_layers` tells the parts apart by
  colour.
* The outline in step 1 is `ident.OUTLINE_COLOR`, the logo's own blue (it was a lighter blue on black).

The lecture videos in `.engine` still open on black with their own copy of `ident.py` and `brand.py`.
Changes made here do not affect them.
