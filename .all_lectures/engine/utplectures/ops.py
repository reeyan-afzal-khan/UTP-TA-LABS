"""Recognise lists and tables of data-structure operations, so they can be shown
as live demonstrations (an index sweeping an array for traversal, cells sliding
apart for insertion ...) instead of rows of text."""

from __future__ import annotations

import re

OPERATIONS = [
    ("traverse", r"travers|\bvisit"),
    ("insert", r"insert|\badd\b|\bpush|enqueue"),
    ("select", r"select|access|\bread\b|retriev"),
    ("search", r"search|\bfind|look\s*up"),
    ("sort", r"\bsort"),
    ("merge", r"merg|combin"),
    ("delete", r"delet|destroy|remov|\bpop\b|dequeue"),
    ("update", r"updat|modif|\bchange"),
    ("create", r"creat|initiali[sz]"),
]

# A one-line piece of code shown with each demonstration.
ARRAY_CODE = {
    "traverse": "for (int i = 0; i < n; ++i) visit(a[i]);",
    "insert": "shift a[2..n-1] right; a[2] = 15;",
    "select": "x = a[3];",
    "search": "for (i = 0; a[i] != 18; ++i) { }",
    "sort": "sort(a, a + n);",
    "merge": "merge(left, right) -> a;",
    "delete": "shift a[2..n-1] left; --n;",
    "update": "a[2] = 40;",
    "create": "int a[5] = {12, 25, 18, 30, 22};",
}
VALUE_CODE = {
    "create": "int x = 42;",
    "select": "cout << x;",
    "update": "x = 7;",
    "delete": "}  // x goes out of scope",
    "traverse": "cout << x;",
    "insert": "x = 42;",
    "search": "if (x == 42) ...",
    "sort": "",
    "merge": "",
}


def classify(text: str) -> str | None:
    t = text.lower()
    for name, pattern in OPERATIONS:
        if re.search(pattern, t):
            return name
    return None


def detect(names: list[str], context: str = "") -> tuple[str, list[str | None]] | None:
    """If most of these names are operations, return (subject, [operation per name])."""
    ops = [classify(n) for n in names]
    found = [o for o in ops if o]
    if len(found) < 3 or len(found) < 0.6 * len(names) or len(set(found)) < 3:
        return None
    ctx = context.lower()
    primitive = ("primitive" in ctx and "non-primitive" not in ctx) or set(found) <= {"create", "select", "update",
                                                                                     "delete"}
    return ("value" if primitive else "array"), ops
