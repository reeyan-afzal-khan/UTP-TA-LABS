"""Read a code listing for narration: what it includes, declares and defines.

The voice-over should not read code aloud character by character. Instead
each listing is walked part by part, highlighting the lines being described:

    #include <iostream>  ...          "It includes iostream and string."
    struct Student { ... };            "The struct Student has four fields: id, name, age, and course."
    int findById(...) { ... }          "The function find by ID takes students, n, and id. It loops ..."

This is a first draft of the narration; refine it in the lecture script.
"""

from __future__ import annotations

import re

from .latex.inline import code_to_speech

NUMBERS = ["no", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
           "eleven", "twelve"]
KEYWORDS = {"if", "for", "while", "switch", "return", "else", "do", "catch", "sizeof", "case"}
STYLE_LANGUAGES = {"utpcpp": "cpp", "utpc": "c", "utppython": "python", "utpr": "r", "utpbash": "bash",
                   "utpterminal": "bash", "utpcnumbered": "c", "utpbashnumbered": "bash"}
LANGUAGE_NAMES = {"cpp": "C++", "c++": "C++", "c": "C", "python": "Python", "r": "R", "bash": "shell",
                  "sh": "shell", "sql": "SQL", "java": "Java", "javascript": "JavaScript", "text": ""}


def say_list(items: list[str]) -> str:
    items = [i for i in items if i]
    if not items:
        return ""
    if len(items) == 1:
        return items[0]
    if len(items) == 2:
        return f"{items[0]} and {items[1]}"
    return ", ".join(items[:-1]) + ", and " + items[-1]


def count_word(n: int) -> str:
    return NUMBERS[n] if n < len(NUMBERS) else str(n)


def lexer_name(language: str | None) -> str:
    lang = (language or "").lower().strip("{} ")
    return {"c++": "cpp", "[iso]c++": "cpp", "python": "python", "r": "r", "bash": "bash", "sh": "bash",
            "shell": "bash", "c": "c", "sql": "sql", "java": "java", "javascript": "javascript",
            "text": "text", "": "text"}.get(lang, lang)


def split_listing(code: str, max_lines: int) -> list[tuple[int, str]]:
    """Split a long listing at top-level boundaries: [(first line number, code)]."""
    lines = code.split("\n")
    if len(lines) <= max_lines:
        return [(1, code)]
    # units: runs of lines between blank lines at brace depth 0 (and Python dedents)
    units: list[list[int]] = []
    cur: list[int] = []
    depth = 0
    for k, line in enumerate(lines):
        stripped = line.strip()
        if not stripped and depth == 0 and cur:
            units.append(cur)
            cur = []
            continue
        if stripped or cur:
            cur.append(k)
        depth += line.count("{") - line.count("}")
    if cur:
        units.append(cur)
    chunks: list[list[int]] = []
    for unit in units:
        while len(unit) > max_lines:                     # a single huge unit: cut it
            chunks.append(unit[:max_lines])
            unit = unit[max_lines:]
        if chunks and len(chunks[-1]) + len(unit) + 1 <= max_lines:
            chunks[-1].extend(unit)
        else:
            chunks.append(list(unit))
    out = []
    for chunk in chunks:
        a, b = chunk[0], chunk[-1]
        out.append((a + 1, "\n".join(lines[a:b + 1])))
    return out


_FUNC = re.compile(r"^\s*(?:template\s*<[^>]*>\s*)?(?:(?:static|inline|virtual|constexpr|extern)\s+)*"
                   r"([A-Za-z_][\w:<>,\s\*&]*?)\s+([\*&]*[A-Za-z_]\w*)\s*\(([^;{]*)\)\s*(?:const)?\s*(\{.*)?$")
_STRUCT = re.compile(r"^\s*(?:typedef\s+)?(struct|class|union|enum)\s+(\w+)?\s*\{?\s*$")
_FIELD = re.compile(r"^\s*(?:const\s+|static\s+|unsigned\s+|long\s+)*[A-Za-z_][\w:<>,]*[\s\*&]+([A-Za-z_]\w*)\s*(\[[^\]]*\])?\s*(=[^;]*)?;")


def _params(text: str) -> list[str]:
    names = []
    for p in text.split(","):
        p = p.strip()
        if not p or p == "void":
            continue
        p = re.sub(r"=.*$", "", p).strip()
        m = re.search(r"([A-Za-z_]\w*)\s*(\[[^\]]*\])?\s*$", p)
        if m:
            names.append(code_to_speech(m.group(1)).strip())
    return names


def _function_sentence(name: str, params: list[str], body: list[str], ret: str) -> str:
    spoken = code_to_speech(name).strip()
    if name == "main":
        return "Finally, main puts the pieces together and runs them in order."
    text = " ".join(body)
    loops = bool(re.search(r"\b(for|while)\s*\(", text)) or bool(re.search(r"^\s*(for|while)\b", text, re.M))
    prints = bool(re.search(r"\bcout\b|\bprintf\s*\(|\bputs\s*\(|\bprint\s*\(|\bcat\s*\(", text))
    sentinel = bool(re.search(r"return\s+-\s*1\s*;|return\s+(?:None|NULL|nullptr|-1)\b", text))
    returns = bool(re.search(r"\breturn\s+[^;\s]", text)) and ret.strip() not in ("void", "")
    recursive = len(re.findall(r"\b" + re.escape(name) + r"\s*\(", text)) > 0
    allocates = bool(re.search(r"\bnew\b|\bmalloc\s*\(", text))
    frees = bool(re.search(r"\bdelete\b|\bfree\s*\(", text))
    first = f"The function {spoken}" + (f" takes {say_list(params)}." if params else " takes no arguments.")
    clauses = []
    if loops:
        clauses.append("loops over " + ("them" if params else "the data"))
    if allocates:
        clauses.append("allocates new memory")
    if frees:
        clauses.append("releases memory")
    if recursive:
        clauses.append("calls itself on a smaller part of the problem")
    if prints:
        clauses.append("prints each one" if loops else "prints the result")
    if sentinel:
        clauses.append("returns the position it finds, or minus one when there is no match")
    elif returns:
        clauses.append("returns the result")
    return first + (" It " + say_list(clauses) + "." if clauses else "")


def c_like_steps(code: str, first_line: int = 1) -> list[dict]:
    lines = code.split("\n")
    steps: list[dict] = []
    includes = [k for k, l in enumerate(lines) if re.match(r"\s*#\s*include|\s*using\s+namespace", l)]
    if includes:
        names = []
        for k in includes:
            m = re.search(r"#\s*include\s*[<\"]([\w./+-]+)[>\"]", lines[k])
            if m:
                names.append(re.sub(r"\.h$", "", m.group(1)))
        if names:
            steps.append({"lines": [first_line + includes[0], first_line + includes[-1]],
                          "say": f"It includes {say_list(names)}."})
    k = 0
    while k < len(lines):
        line = lines[k]
        sm = _STRUCT.match(line)
        fm = _FUNC.match(line) if not sm else None
        if fm and fm.group(2).lstrip("*&") in KEYWORDS:
            fm = None
        if fm and fm.group(1).split()[-1] in KEYWORDS | {"else", "return", "new", "delete"}:
            fm = None
        if not (sm or fm):
            k += 1
            continue
        # find the end of this definition by brace depth
        depth = 0
        end = k
        opened = False
        for j in range(k, len(lines)):
            depth += lines[j].count("{") - lines[j].count("}")
            opened = opened or "{" in lines[j]
            end = j
            if opened and depth <= 0:
                break
        if not opened:                                   # a declaration, not a definition
            k += 1
            continue
        body = lines[k + 1:end]
        if sm:
            kind, name = sm.group(1), sm.group(2) or ""
            fields = [m.group(1) for m in (_FIELD.match(l) for l in body) if m]
            spoken_fields = [code_to_speech(f).strip() for f in fields]
            if kind == "enum":
                say = f"The enum {code_to_speech(name).strip()} names the possible values."
            elif fields:
                say = (f"The {kind} {code_to_speech(name).strip()} has {count_word(len(fields))} "
                       f"field{'s' if len(fields) != 1 else ''}: {say_list(spoken_fields)}.")
            else:
                say = f"The {kind} {code_to_speech(name).strip()} groups the data and the operations on it."
        else:
            say = _function_sentence(fm.group(2).lstrip("*&"), _params(fm.group(3)), body, fm.group(1))
        steps.append({"lines": [first_line + k, first_line + end], "say": say})
        k = end + 1
    return steps


def python_steps(code: str, first_line: int = 1) -> list[dict]:
    lines = code.split("\n")
    steps: list[dict] = []
    imports = [k for k, l in enumerate(lines) if re.match(r"\s*(import|from)\s+\w", l)]
    if imports:
        mods = []
        for k in imports:
            m = re.match(r"\s*(?:from\s+([\w.]+)\s+import|import\s+([\w.]+))", lines[k])
            if m:
                mods.append(code_to_speech((m.group(1) or m.group(2)).split(".")[0]).strip())
        steps.append({"lines": [first_line + imports[0], first_line + imports[-1]],
                      "say": f"It imports {say_list(list(dict.fromkeys(mods)))}."})
    for k, line in enumerate(lines):
        m = re.match(r"(\s*)(def|class)\s+(\w+)\s*(?:\(([^)]*)\))?", line)
        if not m:
            continue
        indent = len(m.group(1))
        end = k
        for j in range(k + 1, len(lines)):
            if lines[j].strip() and len(lines[j]) - len(lines[j].lstrip()) <= indent:
                break
            if lines[j].strip():
                end = j
        body = lines[k + 1:end + 1]
        if m.group(2) == "class":
            say = f"The class {code_to_speech(m.group(3)).strip()} bundles the data with its methods."
        else:
            params = [p for p in _params(m.group(4) or "") if p != "self"]
            say = _function_sentence(m.group(3), params, body, "value")
        steps.append({"lines": [first_line + k, first_line + end], "say": say})
    return steps


def shell_steps(code: str, first_line: int = 1) -> list[dict]:
    steps = []
    for k, line in enumerate(code.split("\n")):
        cmd = line.strip().lstrip("$ ").strip()
        if not cmd or cmd.startswith("#"):
            continue
        words = cmd.split()
        tool = words[0]
        if tool == "cd":
            target = code_to_speech(words[1] if len(words) > 1 else "home").strip()
            say = f"Change into {target}."
        elif tool in ("g++", "gcc", "clang", "clang++", "cc"):
            src = next((w for w in words[1:] if re.search(r"\.(c|cpp|cc|cxx)$", w)), "the source file")
            say = f"Compile {code_to_speech(src).strip()} with {tool}."
        elif tool.startswith("./") or tool.startswith(".\\"):
            say = f"Run {code_to_speech(tool[2:]).strip()}."
        elif tool in ("python", "python3", "py"):
            target = next((w for w in words[1:] if not w.startswith("-")), "the script")
            say = f"Run {code_to_speech(target).strip()} with Python."
        elif tool in ("pip", "pip3", "conda") and "install" in words:
            pkgs = [w for w in words[words.index("install") + 1:] if not w.startswith("-")]
            say = f"Install {say_list([code_to_speech(p).strip() for p in pkgs]) or 'the packages'}."
        elif tool == "make":
            say = "Build it with make."
        else:
            say = f"Run {code_to_speech(tool).strip()}."
        steps.append({"lines": [first_line + k, first_line + k], "say": say})
    return steps


def code_steps(code: str, lexer: str, first_line: int = 1) -> list[dict]:
    if lexer in ("cpp", "c", "java", "javascript", "csharp", "rust", "go"):
        return c_like_steps(code, first_line)
    if lexer == "python":
        return python_steps(code, first_line)
    if lexer == "bash":
        return shell_steps(code, first_line)
    return []
