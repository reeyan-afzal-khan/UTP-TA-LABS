"""Read evaluated Typst content with the pinned official compiler."""
from pathlib import Path
import hashlib
import importlib.util
import json
import subprocess

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location("utp_typst_build", ROOT / ".typst-setup/scripts/build.py")
toolchain = importlib.util.module_from_spec(spec)
spec.loader.exec_module(toolchain)

def evaluate(text):
    folder = ROOT / ".build/lecture-content"
    folder.mkdir(parents=True, exist_ok=True)
    key = hashlib.sha256(text.encode()).hexdigest()[:20]
    source = folder / (key + ".typ")
    source.write_text('#metadata([\n' + text + '\n]) <lecture-content>\n', encoding="utf-8")
    process = subprocess.run([toolchain.compiler(), "eval", "query(<lecture-content>).first().value",
                              "--in", str(source), *toolchain.flags(), "--input", "lecture=true"],
                             check=True, capture_output=True, text=True, encoding="utf-8")
    return json.loads(process.stdout)

def split_top_level(text, separator):
    result, start, depth = [], 0, 0
    for i, ch in enumerate(text):
        if ch in "([{": depth += 1
        elif ch in ")]}": depth -= 1
        elif depth == 0 and text.startswith(separator, i):
            result.append(text[start:i]); start = i + len(separator)
    return result + [text[start:]]

def descendants(node):
    if isinstance(node, dict):
        yield node
        for value in node.values(): yield from descendants(value)
    elif isinstance(node, list):
        for value in node: yield from descendants(value)

def math_source(node):
    if not isinstance(node, dict): return str(node or "")
    func = node.get("func", "").removeprefix("math.")
    if func == "text": return node.get("text", "")
    if func == "space": return " "
    if func == "sequence": return " ".join(math_source(c) for c in node.get("children", []))
    if func == "frac": return '(' + math_source(node.get("num")) + ')/(' + math_source(node.get("denom")) + ')'
    if func == "attach":
        value = math_source(node.get("base"))
        for key, mark in [("b", "_"), ("t", "^")]:
            if key in node: value += mark + '(' + math_source(node[key]) + ')'
        return value
    if func == "equation": return math_source(node.get("body"))
    if func == "root": return 'sqrt(' + math_source(node.get("radicand")) + ')'
    if func in ("lr", "mid", "bold", "upright", "italic", "op", "accent"):
        return math_source(node.get("body", node.get("base", {})))
    if "body" in node: return math_source(node["body"])
    if "child" in node: return math_source(node["child"])
    return " ".join(math_source(v) for v in node.values() if isinstance(v, (dict, list)))

def inline(node):
    if not isinstance(node, dict): return str(node or "")
    func = node.get("func", "")
    if func == "text": return node.get("text", "")
    if func in ("space", "linebreak", "parbreak"): return " "
    if func == "sequence": return "".join(inline(c) for c in node.get("children", []))
    if func == "strong": return '*' + inline(node.get("body", {})) + '*'
    if func == "emph": return '_' + inline(node.get("body", {})) + '_'
    if func == "raw": return '`' + node.get("text", "") + '`'
    if func == "equation": return '$' + math_source(node) + '$'
    if func == "ref": return '@' + str(node.get("target", "")).strip('<>')
    if "body" in node: return inline(node["body"])
    if "child" in node: return inline(node["child"])
    return ""
