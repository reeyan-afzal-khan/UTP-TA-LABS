"""Lecture callouts use the same semantic colours as the book theme."""
from collections import defaultdict
from dataclasses import dataclass, field

@dataclass
class BoxStyle:
    name: str = "callout"
    nargs: int = 1
    title: str = ""
    back: str = "#FFFFFF"
    frame: str = "#246B9E"
    title_back: str = "#246B9E"
    title_color: str = "#FFFFFF"
    options: dict = field(default_factory=dict)
    @property
    def heavy(self): return True

class StyleBook:
    def __init__(self, *unused): self.boxes = defaultdict(BoxStyle)
    def is_callout(self, name): return True
    def title_markup(self, name, args): return args[0] if args else name.replace('-', ' ').title()
    def register(self, name, color):
        self.boxes[name] = BoxStyle(name=name, frame=color, title_back=color)
