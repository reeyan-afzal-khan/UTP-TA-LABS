# UTP lecture engine

Narrated lecture videos, made from the course LaTeX with [Manim Community](https://www.manim.community/):
1080p, 60 fps, a neural voice-over now and your own voice later. Each chapter and lab file becomes one video
with the same name:

```text
ALGORITHMS & DATA STRUCTURES/chapters/01-introduction.tex
  -> .all_lectures/algorithms-data-structures/chapters/01-introduction.mp4      the video
     .all_lectures/algorithms-data-structures/chapters/01-introduction.py       its Manim code: edit, then run it
     .all_lectures/algorithms-data-structures/chapters/01-introduction.srt      subtitles
     .all_lectures/algorithms-data-structures/chapters/01-introduction.script.yaml   the same script as data
```

To change a video yourself: open its `.py`, edit, and run `python 01-introduction.py` (see
[Changing a video](#changing-a-video)).

## How it works

```text
chapter / lab .tex ──read──> blocks ──> lecture script (YAML) ──> voice per cue ──> Manim scene ──> .mp4 + .srt
                                        ▲ edit this to refine     ▲ TTS or your       ▲ paced by the
                                                                    recordings          audio, never by hand
```

1. **Reading the LaTeX** (`utplectures/latex/`). Headings, paragraphs, lists, every callout box, code
   listings, tables, figures and equations become blocks. Box colours and titles are read from
   `.shared/utpnotes.tex` and the course `main.tex`, so a box a course adds later just works.
2. **The script** (`script.py`). Blocks become scenes: a title card, the chapter guide, section cards,
   key-word scenes for prose and boxes, bullet lists, code, tables, figures, operation demos, the recap and
   an outro pointing to the next lecture. Each scene has *cues*, stretches of narration. The voice reads the
   book's own text, made speakable (`O(\log n)` is "O of log n", `findById()` is "find by ID"); the screen
   shows only what helps the eye:
   * **Prose and boxes** show, per sentence, the terms the author marked (`\term{trees}` -> a chip), the
     items of a list in the sentence (organized · related · stored · accessed), or a short sentence as a
     headline (`beats.py`). Never a wall of text.
   * **Code runs on screen** (`minicpp.py`, `trace.py`). Each C/C++ listing is executed by a small
     interpreter that keeps the chapter's variables between listings; its memory is drawn beside the code
     and every step is animated in time with the narration: a field fills as its line lights up, the loop
     index slides along the array, comparisons tick or cross, output appears in a console.
     Records, arrays, arrays of records and scalars are drawn as boxes (`render/viz.py`); nodes made with
     `new` are drawn as a linked structure (`render/heap.py`, model in `heapmodel.py`): singly, doubly and
     circular lists in a row, trees by level, pointer variables (`head`, `p`, `root`) as labels with
     arrows. A node not yet linked in waits below the row; links swing to their new targets; `delete`
     flashes the node red and frees it. The narration names nodes the way the picture shows them
     ("head's next points to a new node holding 25", "p moves on to 25"). Listings the interpreter
     cannot run are walked through with line highlights.
   * **Code demos written for the video** (`.all_lectures/<course>/demos.yaml`). The book explains, the
     video shows: a short runnable listing can be added after any heading (primitive variables, an array
     loop, a linked list, a tree for Chapter 1). It runs and is narrated exactly like the book's listings.
   * **Operations** (traversal, insertion, selection, searching, sorting, merging, deletion; create,
     access, update, destroy) listed in a table or list are demonstrated on an array or a variable
     (`ops.py`, `render/opsdemo.py`).
3. **The voice** (`voice.py`). Every cue is synthesised by a neural voice (edge-tts) with word timings, or
   taken from your own recording. Audio is cached, so a rebuild only re-synthesises changed cues.
4. **The figures** (`figures.py`). TikZ and pgfplots figures are compiled with the course's own preamble
   (same fonts and node styles as the PDF), converted to SVG, recoloured for black in the UTP palette
   (`render/widgets.py: dark_color`), and drawn on screen part by part.
5. **The render** (`render/`). One Manim scene plays the whole lecture. Every animation starts at a cue
   or at a word inside a cue, and every hold lasts until the audio ends, so swapping the voice re-paces
   the video by itself.

Nothing rebuildable is written into the repository: TTS audio, compiled figures and Manim's frames live in
`%LOCALAPPDATA%\utp-lectures` (set `UTP_LECTURES_CACHE` to move it).

## Setup (once)

```bash
conda create -y -n utp_lectures python=3.12
```

```bash
conda run -n utp_lectures python -m pip install -r .all_lectures/engine/requirements.txt
```

Also needed, already on this PC: MiKTeX (pdflatex, pdftocairo, pdfinfo, for figures and equations) and
ffmpeg. Check with:

```bash
python .all_lectures/engine/lecture.py doctor
```

`lecture.py` finds the `utp_lectures` environment by itself, so any Python can start it.

## Making videos

```bash
python .all_lectures/engine/lecture.py list ADS
```

```bash
python .all_lectures/engine/lecture.py build ADS ch1
```

| Command | What it does |
| --- | --- |
| `build ADS ch1 lab1` | render and publish Chapter 1 and Lab 1 (1080p60) |
| `build ADS` | every chapter and lab of the course |
| `build ADS ch1 --stills` | layout check in about a minute: a full-size still at the end of every cue, no video |
| `build ADS ch1 --draft` | quick 540p30 video in the cache, not published |
| `build ADS ch1 --rescript` | throw away script edits and regenerate it from the LaTeX |
| `script ADS ch1` | write the editable script only |
| `voice-sheet ADS ch1` | a recording sheet for your own narration |

Course codes: ADS, AI, DCN, DS, ERP, FI, ML, OS (or a folder name). Lectures: `ch3`, `lab2`, or a file
name such as `01-introduction`. A 9-minute chapter renders in about 10 minutes on this PC.

## Changing a video

**The content changed in the LaTeX.** Rebuild. The script is regenerated from the LaTeX, the voice only
re-synthesises changed sentences, and figures are only recompiled when their TikZ changed.

**Anything in one video: its Manim code.** Next to every video is `<name>.py`, the video as Python:
one method per scene, the narration as plain strings, the code demos as code, and room for scenes of
your own in plain Manim. Edit it and run it; no other step is needed.

```bash
python .all_lectures/algorithms-data-structures/chapters/01-introduction.py --only s22
```

```python
    def s22(self):
        return code(
            code="""
                struct Node { int value; Node* next; };
                Node* head = new Node{12, nullptr};
                ...
            """,
            say={
                '038': cue('head points to a new node holding 12.', beats=[3, 3]),
                ...
            },
        )

    @manim_scene(say=["A stack is like a pile of plates: [show] push puts one on top."])
    def s22b(self, v):                          # your own scene, in plain Manim
        plates = VGroup(*[RoundedRectangle(width=2.4, height=0.35, corner_radius=0.08,
                                           color=v.theme.c("blue")) for _ in range(3)])
        yield [LaggedStart(*[FadeIn(p, shift=DOWN * 0.3) for p in plates.arrange(UP)])]
        yield [FadeIn(plates[-1].copy().set_color(v.theme.c("gold")).next_to(plates, UP))]
```

| Run | What it does |
| --- | --- |
| `python <name>.py` | the video, 1080p 60 fps, published next to the file with its subtitles |
| `python <name>.py --only s22 s22b` | just those scenes, as a quick draft (seconds, not minutes) |
| `python <name>.py --stills` | a full-size still per cue: every layout checked in a couple of minutes |
| `python <name>.py --draft` | the whole video at 540p 30 fps |

* Scenes play in the order the methods are written; reorder, delete or add them (`s22b`, `s40x` ...).
* Change a sentence in `say=` and only that cue gets a new voice; the screen is timed by the voice.
* The helpers (`title`, `prose`, `bullets`, `callout`, `code`, `table`, `figure`, `operations` ...) and
  `@manim_scene` are documented in `utplectures/kit.py`; all of Manim is imported for your own scenes.
* Any Python works: the file re-runs itself under the `utp_lectures` environment.
* `lecture.py build` writes the `.py` from the LaTeX. Once you have edited it, `lecture.py build` keeps
  and builds your version; `--rescript` regenerates it (and the script) from the LaTeX.

**The same script as data.** `<name>.script.yaml` holds the same scenes as YAML, for edits without Python:

```yaml
- id: s03
  type: prose
  show:                                   # one entry per spoken sentence
  - A data structure is not just a container          # a headline
  - [organized, related, stored, accessed]            # a row of chips
  - ''                                                # keep what is on screen
  cues:
  - id: '004'
    say: A data structure is not just a container. [show] It is a decision about how data will be
      organized, related, stored, and accessed in memory. [show] That decision affects ...
```

* Each cue reveals the next *step* of its scene (the next `show` entry, bullet, row, operation) as it
  starts; `[show]` inside `say` reveals another step at exactly that word.
* A `show` entry is a string (headline, Pango markup allowed), a list (chips), `{label: ..., chips: [...]}`,
  or `''` (nothing new).
* On a code scene, `beats: [a, b]` plays steps a..b of the running code during the cue (one per `[show]`);
  `lines: [5, 10]` instead just highlights those lines. The steps themselves come from running the code, so
  editing the `code:` of a scene changes what is animated.
* On an operations scene, `items[].op` picks the demonstration (traverse, insert, select, search, sort,
  merge, delete, update, create) and `subject` is `array` or `value`.
* `pause: 4` after a cue holds a silent "pause and think" for 4 seconds.
* Delete, reorder or add scenes and cues freely; cue ids just need to stay unique.

Once you edit a script, the engine keeps your version even when the LaTeX changes, and warns you that the
source has moved on. `--rescript` starts again from the LaTeX.

**What the videos leave out.** They lean on code, not theory: `script.skip_boxes` in `config/engine.yaml`
lists the boxes about the book itself (slide alignment, clarifications, lab modes) that are not voiced.

**The look.** Pitch black with UTP blue and gold. The UTP logo is rebuilt once as vector art from
`.shared/logos/logo-UTP.png` (`render/brand.py`): the oval is an exact fitted ellipse, the gold lines are
traced at 8x from soft colour coverage and made exactly symmetric (the left half, mirrored about the
design's own axis), and the wordmark is set in Georgia, the closest installed serif, each letter fitted to
the box of the original letter. Every video of every course opens on the logo drawing itself
(`render/ident.py`, all timings are constants at its top): the oval's boundary is drawn from the top, the
blue fades in inside it; then the gold flows up through
the engraved lines from their feet, each flow front carrying a small light (the flow stages are traced
from the exact artwork once, by distance along the lines, in `brand.py`, so the lines always have their
final width and both halves flow in step); the wordmark tracks in while the gold rules grow from the centre, and a soft light
sweeps the emblem. It then settles beside the title, and its emblem sits in the corner. To review a change to it in seconds, render it alone:

```bash
python .all_lectures/engine/logo_intro.py
```

which writes `.all_lectures/utp-logo-intro.mp4` (about 7 s, standard H.264): the logo and its wordmark draw
themselves, hold, then fade slowly to black (`ident.OUTRO_HOLD`, `OUTRO_FADE`, `OUTRO_BLANK`; `--title`
adds a sample chapter title card after it). Everything is drawn with Cairo's best antialiasing
(`player.best_antialias`). The text face is the first installed of
`theme.font` (Adobe Jenson Pro, then
Palatino Linotype, then Source Sans 3): Jenson is a licensed Adobe font, so install it on this PC and the
videos pick it up. `config/engine.yaml` holds the colours (`theme`, and `theme.markup` for what the book's
inline colours become), fonts (code in Source Code Pro, bundled in `assets/fonts`), text sizes, pacing
(pauses, transition and reveal times), voice, and video size. A course can override any of it in
`.all_lectures/<course-slug>/lectures.yaml`. The layouts are in `utplectures/render/templates.py` (one class
per scene type), the memory drawings in `render/viz.py`, the operation demos in `render/opsdemo.py`.

**Pronunciation.** `config/pronunciations.yaml` maps what is written to what is said (`C++` -> "C plus
plus", `Week I` -> "Week 1"). Add course-specific rules in `.all_lectures/<course-slug>/pronunciations.yaml`.

**A figure that deserves a hand-made animation.** Drop a Python file named after the figure's label in
`overrides/<course-slug>/`, e.g. `overrides/algorithms-data-structures/fig-same-data.py`, defining
`build(theme)` (returns the Manim mobject to show instead of the compiled figure) and/or `reveal(mobject)`
(returns the animations that bring it in). See `overrides/README.md`.

## Your own voice

```bash
python .all_lectures/engine/lecture.py voice-sheet ADS ch1
```

This writes `.all_lectures/<course>/voice/chapters/<name>/RECORDING-SHEET.md`, listing every cue with its
number. Record each cue as its own file in that folder (`001.wav`, `002.wav`, ...; `.wav`, `.mp3`, `.m4a`
or `.flac`) and rebuild. Recorded cues replace the TTS voice; cues you have not recorded yet keep it, so you
can record a section at a time. Silence at both ends is trimmed and the loudness is normalised, and since
every animation is placed by the audio, the video re-paces itself to your delivery.

`voice.mode` in `config/engine.yaml` chooses: `auto` (your recording where there is one), `tts`, or
`recorded` (fail if a cue has no recording).

Planned next: recording a whole lecture in one take and letting Whisper split and align it to the cues.
The cue structure is already built for it: an aligner only has to write `001.wav`, `002.wav`, ... into
the same folder, plus word timings for sentence-level sync.

## Notes for maintainers

* Rendering runs in a separate process per lecture (`render/worker.py`), so one failure does not stop a
  batch (`--keep-going`).
* Manim's partial movies are encoded at x264 CRF 16, tuned for animation (`video.crf`), instead of
  Manim's default 23, which bands flat colours.
* `register_fonts` in `render/text.py` loads the bundled fonts once. On Windows, manimpango re-adds
  registered font files to Pango on every text it draws, leaking about 400 MB per text; don't call
  `manimpango.register_font` anywhere else.
* Manim sets Cairo's line cap only for VMobjects whose `cap_style` is not AUTO and never resets it, so
  one round-capped stroke makes every later zero-length outline (text about to be `Write`n) a dot.
  Leave `cap_style` alone.
* Manim writes every `play` as its own video segment and the encoder restarts at each, so a seam can
  show as a slight jolt in flat colours where one play ends and the next begins. The logo intro is
  therefore one continuous play (`ident.as_one_shot`), with its final hold inside it. Inside one play,
  `FadeIn`/`Create` add their mobject on top of everything else animated with it; fade a bottom layer
  with an `UpdateFromAlphaFunc` instead (`ident.fade_up`).
* Never fade out a parent group whose children were revealed one by one: Manim restores the children
  afterwards. The player fades out the scene's own top-level mobjects at each transition.
* Figure parts are revealed by changing their opacity inside one group, not with `FadeIn` on each
  part, because `FadeIn` re-stacks parts and would put a cell's fill over its number. For the same reason
  a beat of running code plays its parts in one `play` with delayed easing (`viz.delayed`) instead of a
  `LaggedStart`, which would lift each memory box above its value.
* The C++ interpreter (`minicpp.py`) runs the book's listings and whole lab programs: structs and
  classes (methods, constructors with initialiser lists, static members, a counting `operator new`),
  enums, pointers and references, `new`/`delete`, arrays, `vector`/`stack`/`queue`/`string`,
  `<algorithm>` basics, `switch`, default arguments, cout/printf formatting. 21 of the 26 ADS lab
  programs run under it with all their own self-checks passing. Not run: lambdas, unions, structured
  bindings, `pair`/`map` (Lab 7's binary tree, Lab 9, the union review); such listings fall back to line
  highlighting. A run is animated up to 90 beats (`trace.MAX_BEATS`).
* The heap picture is laid out again after every beat and the difference is animated; everything is
  sized once, from a replay of the whole trace, so the panel never jumps. Moves finish before new links
  are drawn (`heap.HeapW._sync`).
