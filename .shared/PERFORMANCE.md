# Compilation performance

The normal build now optimizes the shared box renderer directly. There is no
Memoize dependency, diagram cache, extraction step, shell-escape requirement,
or Python requirement for compiling a course. Upload the course and `.shared/`
with their existing relative structure and compile `main.tex` normally.

## What changed

Profiling the 298-page ML book without caching attributed about 11 seconds to
box drawing, 6–7 seconds to course diagrams, and 2 seconds to code listings.
The box time includes repeated creation of invisible TikZ geometry nodes.

`style/rendering.tex` gives the shared flat-colour boxes equivalent PGF vector
fills. It preserves the original rounded corners, colours, text dimensions,
padding, and open edges where a box continues across a page. tcolorbox still
handles content layout and pagination. The decorated cover continues using
the original enhanced skin. This is a source-level optimization on every build,
including immediately after edits.

`style/listings.tex` resolves repeated colour mixtures once. Syntax highlighting,
fonts, line wrapping, frames and line numbers remain unchanged. Actual TikZ
course diagrams remain source drawings at their original resolution and detail.

The previous generated-cache implementation and its 1,913 files (106.2 MiB)
were removed. No cache refresh or special upload is needed.

## Why not replace TikZ or listings wholesale?

- A vector PDF can preserve a finished diagram's appearance, but editing its
  source then requires regenerating that asset. That is useful for deliberately
  fixed illustrations, not a transparent replacement for editable diagrams.
- Plain verbatim code removes syntax highlighting and changes the listing
  behaviour. It does not meet the same-output requirement here.
- Raster images of code or diagrams are not a quality-preserving substitute.

The profile did not justify a new code-highlighting engine or pre-generation
workflow. Optimize the expensive drawing operations while keeping the source
formats and teaching content maintainable.

## Maintaining the shared style

Use the existing shared box constructors, or `utpplain` for a new flat box.
For shadows, overlays, borderlines or other enhanced effects, use `enhanced`
explicitly. With `\utpnewcallout`, pass it in the trailing option list:

```latex
\utpnewcallout[enhanced,borderline west={1pt}{0pt}{UTPGold}]
  {specialnote}{white}{UTPBlue}{Special note}
```

The custom renderer uses existing tcolorbox/PGF helpers. It falls back to the
original enhanced skin if the required helpers are unavailable. To use the
original renderer for diagnosis, put this before the shared-style input:

```latex
\def\utpfastboxes{0}
```

Prism's installed package versions and server timings have not been verified
in an authenticated session. These changes require only the packages already
used by the courses; they do not depend on Prism preserving auxiliary files.

## Verifying appearance after changes

Compile reference and updated PDFs into separate temporary directories. Then:

```powershell
python -m pip install -r .shared/tools/requirements.txt
python .shared/tools/verify_layout.py before.pdf after.pdf
```

The checker verifies page count, page dimensions, text character inventory,
and every page render. It checks at 96 dpi with bounded antialiasing tolerance;
exceptions must pass a stricter independent render at 144 dpi. Rendered images
are only verification intermediates; the actual documents remain vector PDFs.
The printed work directory is retained for inspection if a check fails.

All compilation measurements below are local pdfLaTeX results, not Prism
benchmarks. Host load and package versions affect absolute times.

## Verified results

All nine courses passed the comparison: **1,164 pages**, with matching page
counts, text inventories and page geometry, plus full-page visual checks.
There were no undefined references or overfull boxes. The normal build logs
confirmed that Memoize was not loaded.

Two alternating original/optimized builds were measured sequentially after
references and contents had stabilized. The original renderer was selected
with `\def\utpfastboxes{0}`; optimized builds used ordinary `main.tex`.
Both paths included the identical listing-colour precomputation.

| Course | Original renderer | Optimized renderer | Reduction |
| --- | ---: | ---: | ---: |
| MACHINE LEARNING | 27.0 s | 21.3 s | 21.1% |
| ALGORITHMS & DATA STRUCTURES | 15.9 s | 13.7 s | 14.0% |

These gains are relative to source rendering with the original box engine,
not the previous generated-cache experiment. The improvement is about 14–21%
in these two local examples; this is not a claim of a dramatic Prism speedup.
The main additional benefit is eliminating cache assets, package dependencies
and refresh work while keeping diagrams and code editable.

`.courses`, `.engine` and the published PDFs were not changed.
