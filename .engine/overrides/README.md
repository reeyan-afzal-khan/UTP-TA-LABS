# Figure overrides

By default a figure is the book's own SVG, drawn on screen part by part. When a figure
deserves a hand-made animation, put a Python file here named after its Typst label, in the course's folder:

```text
overrides/algorithms-data-structures/fig-linear-shape.py      for <fig:linear-shape>
```

(`:` and other punctuation in the label become `-`.) The file can define either function or both:

```python
from manim import Arrow, FadeIn, GrowArrow, LaggedStart, RIGHT, Square, Text, VGroup


def build(theme):
    """Return the mobject shown instead of the compiled figure (it is scaled to fit)."""
    cells = VGroup(*[Square(1.2, color=theme.c("blue")) for _ in "ABCD"]).arrange(RIGHT, buff=0.9)
    labels = VGroup(*[Text(ch, font=theme.font, color=theme.c("navy")).move_to(c) for ch, c in zip("ABCD", cells)])
    arrows = VGroup(*[Arrow(a.get_right(), b.get_left(), buff=0.1, color=theme.c("teal"))
                      for a, b in zip(cells, cells[1:])])
    return VGroup(cells, labels, arrows)


def reveal(fig):
    """Return the animations that bring the figure in (they run as the figure's first cue starts)."""
    cells, labels, arrows = fig
    return [LaggedStart(FadeIn(cells), FadeIn(labels), *[GrowArrow(a) for a in arrows], lag_ratio=0.3)]
```

`theme.c("navy")`, `theme.c("teal")` ... are the book's colours; `theme.font` and `theme.mono` its fonts.
The caption, card and narration stay as the script has them. Rebuild the lecture to see it.
