"""A small C++ interpreter for the code in the course books and lab programs.

It runs the C++ a data-structures course is written in: structs and classes
(fields, methods, constructors), scalars and strings, arrays, std::vector /
queue / stack, pointers (new, delete, ->, &, *, pointer arithmetic over
arrays), references, functions (recursion included), if / for / while /
range-for, break / continue, cout (with setw / setprecision) and printf, and
a program's main(). Memory is modelled as cells (Box), so a pointer or a
reference really is "the same cell", exactly as in C++.

While it runs it records what happens, line by line:

    decl     a variable comes into existence          int target = 1003;
    assign   a value changes                          s.id = 1001;  ++i;  p = p->next
    new      a node is allocated on the heap          new Node{12, nullptr}
    delete   a node is released                       delete old;
    push/pop a vector, stack or queue grows or shrinks
    loop     a for-loop begins another pass           i = 2
    cond     an if / loop condition is checked        students[i].id == target -> true
    print    text reaches the console                 cout << ...
    call     a function is entered                    findById(students, 5, 1003)
    break, return, struct, field, func

The lecture turns those events into animations synchronised with the
narration. Anything outside this subset raises CppError, and the lecture
simply shows the code without a trace.
"""

from __future__ import annotations

import copy
import re
from dataclasses import dataclass, field
from typing import Any

MAX_STEPS = 60000              # a runaway guard only: trace.py decides how much is animated
MAX_DEPTH = 120


class CppError(Exception):
    pass


# ------------------------------------------------------------------- lexing

_TOKEN = re.compile(r"""
    (?P<ws>[ \t\r\n]+)
  | (?P<comment>//[^\n]*|/\*.*?\*/)
  | (?P<pre>\#[^\n]*)
  | (?P<num>0[xX][0-9a-fA-F]+|\d+\.\d*(?:[eE][-+]?\d+)?[fF]?|\.\d+(?:[eE][-+]?\d+)?[fF]?|\d+[uUlL]*)
  | (?P<str>"(?:\\.|[^"\\\n])*")
  | (?P<chr>'(?:\\.|[^'\\\n])')
  | (?P<id>[A-Za-z_]\w*)
  | (?P<op><<=|>>=|<<|>>|==|!=|<=|>=|&&|\|\||\+\+|--|\+=|-=|\*=|/=|%=|->|::|[-+*/%<>=!&|^~?:;,.(){}\[\]])
""", re.S | re.X)


@dataclass
class Tok:
    kind: str
    val: str
    line: int
    start: int
    end: int


IGNORED_WORDS = {"explicit", "inline", "virtual", "noexcept", "override", "final", "[[nodiscard]]"}


def tokenize(code: str) -> list[Tok]:
    out, pos, line = [], 0, 1
    while pos < len(code):
        m = _TOKEN.match(code, pos)
        if not m:
            raise CppError(f"cannot read {code[pos:pos + 10]!r}")
        kind = m.lastgroup
        text = m.group(0)
        if kind not in ("ws", "comment", "pre") and text not in IGNORED_WORDS:
            out.append(Tok(kind, "const" if text == "constexpr" else text, line, m.start(), m.end()))
        line += text.count("\n")
        pos = m.end()
    out.append(Tok("eof", "", line, len(code), len(code)))
    return out


_ESC = {"n": "\n", "t": "\t", "\\": "\\", "'": "'", '"': '"', "0": "\0", "r": ""}


def unescape(s: str) -> str:
    return re.sub(r"\\(.)", lambda m: _ESC.get(m.group(1), m.group(1)), s)


# -------------------------------------------------------------------- nodes

@dataclass
class Node:
    line: int = 0
    src: str = ""


@dataclass
class Lit(Node):
    value: Any = None


@dataclass
class Name(Node):
    id: str = ""


@dataclass
class Member(Node):
    obj: Node = None
    field: str = ""
    arrow: bool = False


@dataclass
class Index(Node):
    obj: Node = None
    index: Node = None


@dataclass
class Call(Node):
    func: Node = None                 # Name or Member (a method)
    args: list = field(default_factory=list)


@dataclass
class Unary(Node):
    op: str = ""
    expr: Node = None
    postfix: bool = False


@dataclass
class Binary(Node):
    op: str = ""
    left: Node = None
    right: Node = None


@dataclass
class Assign(Node):
    op: str = "="
    target: Node = None
    value: Node = None


@dataclass
class Ternary(Node):
    cond: Node = None
    a: Node = None
    b: Node = None


@dataclass
class InitList(Node):
    items: list = field(default_factory=list)


@dataclass
class New(Node):
    type: str = ""
    args: list | None = None          # constructor / aggregate arguments
    count: Node = None                # new T[n]


@dataclass
class Cast(Node):
    type: str = ""
    expr: Node = None


@dataclass
class VarDecl(Node):
    type: str = ""
    decls: list = field(default_factory=list)      # [(name, dims, init, is_ptr, is_ref)]
    const: bool = False


@dataclass
class ExprStmt(Node):
    expr: Node = None


@dataclass
class Block(Node):
    body: list = field(default_factory=list)


@dataclass
class If(Node):
    cond: Node = None
    then: Node = None
    other: Node = None


@dataclass
class For(Node):
    init: Node = None
    cond: Node = None
    step: Node = None
    body: Node = None
    end_line: int = 0


@dataclass
class RangeFor(Node):
    type: str = ""
    name: str = ""
    by_ref: bool = False
    seq: Node = None
    body: Node = None
    end_line: int = 0


@dataclass
class While(Node):
    cond: Node = None
    body: Node = None
    do: bool = False
    end_line: int = 0


@dataclass
class Switch(Node):
    subject: Node = None
    cases: list = field(default_factory=list)      # [(label Node | None for default, [statements])]
    end_line: int = 0


@dataclass
class Jump(Node):
    kind: str = ""          # break | continue | return
    value: Node = None


@dataclass
class Delete(Node):
    expr: Node = None


@dataclass
class FuncDef(Node):
    ret: str = ""
    name: str = ""
    params: list = field(default_factory=list)     # [(type, name, is_array, by_ref, is_ptr)]
    body: Block = None
    end_line: int = 0
    inits: list = field(default_factory=list)      # constructor initialiser list [(field, [args])]
    owner: str = ""                                # the class of a method
    defaults: dict = field(default_factory=dict)   # parameter index -> default value expression


@dataclass
class StructDef(Node):
    name: str = ""
    fields: list = field(default_factory=list)     # [(type, name, line, dims, init, is_ptr)]
    methods: dict = field(default_factory=dict)    # name -> [FuncDef]
    end_line: int = 0
    statics: list = field(default_factory=list)    # [(type, name, init)]
    hooks: dict = field(default_factory=dict)      # "new"/"delete" -> statements of a class operator new/delete


@dataclass
class EnumDef(Node):
    name: str = ""
    values: list = field(default_factory=list)     # [(name, Node | None)]


# ------------------------------------------------------------------- parser

BASE_TYPES = {"int", "long", "short", "unsigned", "signed", "double", "float", "char", "bool", "string",
              "void", "auto", "size_t"}
CONTAINERS = {"vector", "queue", "stack", "deque", "list"}
QUALIFIERS = {"const", "static", "constexpr", "volatile", "inline", "virtual", "explicit", "mutable"}


class Parser:
    def __init__(self, code: str, types: set[str] | None = None):
        self.code = code
        self.toks = tokenize(code)
        self.i = 0
        self.types = set(BASE_TYPES) | CONTAINERS | set(types or ())

    def peek(self, k: int = 0) -> Tok:
        return self.toks[min(self.i + k, len(self.toks) - 1)]

    def next(self) -> Tok:
        t = self.toks[self.i]
        self.i += 1
        return t

    def at(self, val: str, k: int = 0) -> bool:
        t = self.peek(k)
        return t.val == val and t.kind in ("op", "id")

    def accept(self, val: str) -> bool:
        if self.at(val):
            self.i += 1
            return True
        return False

    def expect(self, val: str) -> Tok:
        if not self.at(val):
            t = self.peek()
            raise CppError(f"line {t.line}: expected {val!r}, found {t.val!r}")
        return self.next()

    def src(self, start: Tok) -> str:
        return self.code[start.start:self.toks[self.i - 1].end]

    def skip_balanced(self, open_: str, close: str) -> None:
        depth = 0
        while self.peek().kind != "eof":
            v = self.next().val
            if v == open_:
                depth += 1
            elif v == close:
                depth -= 1
                if depth <= 0:
                    return

    # types
    def is_type_start(self, k: int = 0) -> bool:
        t = self.peek(k)
        if t.kind != "id":
            return False
        if t.val in QUALIFIERS or t.val in self.types or t.val in ("struct", "class"):
            return True
        return t.val == "std" and self.peek(k + 1).val == "::"

    def parse_type(self) -> tuple[str, bool]:
        """A type name ('int', 'Student', 'vector<int>'); pointer stars are read by the caller."""
        const = False
        while self.peek().kind == "id" and self.peek().val in QUALIFIERS:
            const = const or self.next().val in ("const", "constexpr")
        if self.at("struct") or self.at("class"):
            self.next()
        if self.at("std") and self.at("::", 1):
            self.next()
            self.next()
        words = []
        while self.peek().kind == "id" and (self.peek().val in self.types or not words):
            words.append(self.next().val)
            if words[-1] not in ("long", "short", "unsigned", "signed"):
                break
        while self.peek().kind == "id" and self.peek().val in ("int", "long", "double", "char") and words:
            words.append(self.next().val)
        name = " ".join(words) or "int"
        if self.at("<"):                                   # vector<int>, queue<Node*> ...
            start = self.i
            self.next()
            depth = 1
            while depth and self.peek().kind != "eof":
                v = self.next().val
                depth += {"<": 1, ">": -1, ">>": -2}.get(v, 0)
            inner = self.code[self.toks[start].end:self.toks[self.i - 1].start].strip()
            if self.toks[self.i - 1].val == ">>":
                inner += ">"
            inner = re.sub(r"\bstd::", "", inner)
            name = f"{name}<{inner}>"
        while self.peek().kind == "id" and self.peek().val == "const":
            self.next()
            const = True
        return name, const

    def static_member_definition(self) -> bool:
        """type Class::name = value;  or  type Class::name;"""
        k = 0
        while self.peek(k).kind == "id" and self.peek(k).val in QUALIFIERS | BASE_TYPES:
            k += 1
        return (self.peek(k).kind == "id" and self.at("::", k + 1) and self.peek(k + 2).kind == "id"
                and (self.at("=", k + 3) or self.at(";", k + 3)))

    def looks_like_function(self) -> bool:
        save = self.i
        try:
            if not self.is_type_start():
                return False
            self.parse_type()
            while self.at("*") or self.at("&"):
                self.next()
            if self.peek().kind == "id" and self.at("::", 1):  # Type Class::method(
                self.next()
                self.next()
            return self.peek().kind == "id" and self.at("(", 1)
        except CppError:
            return False
        finally:
            self.i = save

    # program
    def program(self) -> list[Node]:
        items = []
        while self.peek().kind != "eof":
            if self.at("using") or self.at("namespace") or self.at("typedef") or self.at("template"):
                if self.at("template"):
                    raise CppError("templates are not animated")
                while not self.at(";") and self.peek().kind != "eof":
                    self.next()
                self.accept(";")
                continue
            if self.at("enum"):
                items.append(self.enum_def())
            elif (self.at("struct") or self.at("class")) and (self.at("{", 2) or self.at("{", 1) or self.at(":", 2)):
                items.append(self.struct_def())
            elif self.static_member_definition():
                while not self.at(";"):                       # int Node::live = 0;  (a static member)
                    self.next()
                self.next()
            elif self.looks_like_function():
                items.append(self.func_def())
            else:
                items.append(self.statement())
        return items

    def enum_def(self) -> EnumDef:
        start = self.expect("enum")
        self.accept("class") or self.accept("struct")
        name = self.next().val if self.peek().kind == "id" else "anon"
        self.types.add(name)
        if self.accept(":"):
            self.parse_type()
        values = []
        self.expect("{")
        while not self.at("}"):
            vname = self.next().val
            expr = self.ternary() if self.accept("=") else None
            values.append((vname, expr))
            if not self.accept(","):
                break
        self.expect("}")
        self.accept(";")
        return EnumDef(start.line, self.src(start), name, values)

    def struct_def(self) -> StructDef:
        start = self.next()
        name = self.next().val if self.peek().kind == "id" else "anon"
        self.types.add(name)
        if self.accept(":"):                                 # base classes: read and ignore
            while not self.at("{"):
                self.next()
        self.expect("{")
        sd = StructDef(start.line, "", name)
        while not self.at("}"):
            if self.peek().val in ("public", "private", "protected") and self.at(":", 1):
                self.next()
                self.next()
                continue
            if self.at("friend") or self.at("using") or self.at("typedef"):
                while not self.at(";"):
                    self.next()
                self.next()
                continue
            line = self.peek().line
            save = self.i
            # constructor / destructor:  Name(...)  ~Name(...)
            if (self.peek().val == name and self.at("(", 1)) or (self.at("~") and self.peek(1).val == name):
                if self.at("~"):
                    self.next()
                    self.next()
                    self.skip_balanced("(", ")")
                    self.accept("const")
                    if self.at("{"):
                        self.skip_balanced("{", "}")
                    else:
                        while not self.at(";"):
                            self.next()
                        self.next()
                    continue
                self.next()
                f = self.func_rest(name, "", start, name, ctor=True)
                sd.methods.setdefault(name, []).append(f)
                continue
            is_static = self.peek().val == "static"
            ahead = [self.peek(k).val for k in range(6)]
            if "operator" in ahead:                                  # operator overloads: skip ...
                hook = ahead[ahead.index("operator") + 1] if ahead.index("operator") < 5 else ""
                while not (self.at(";") or self.at("{")):
                    self.next()
                if self.at("{") and hook in ("new", "delete"):      # ... but keep the body of a counting
                    self.next()                                      # operator new/delete (++live;)
                    stmts = []
                    while not self.at("}"):
                        if self.at("return") or self.at("::"):       # the real allocation: not animated
                            while not self.at(";"):
                                self.next()
                            self.next()
                        else:
                            stmts.append(self.statement())
                    self.next()
                    sd.hooks[hook] = stmts
                elif self.at("{"):
                    self.skip_balanced("{", "}")
                else:
                    self.next()
                continue
            if self.looks_like_function():
                ret, _ = self.parse_type()
                while self.at("*") or self.at("&"):
                    self.next()
                mname = self.next().val
                f = self.func_rest(mname, ret, start, name)
                sd.methods.setdefault(mname, []).append(f)
                continue
            self.i = save
            ftype, _ = self.parse_type()
            while True:
                is_ptr = False
                while self.at("*") or self.at("&"):
                    is_ptr = is_ptr or self.peek().val == "*"
                    self.next()
                fname = self.next().val
                dims = []
                while self.accept("["):
                    dims.append(self.expr() if not self.at("]") else None)
                    self.expect("]")
                init = None
                if self.accept("="):
                    init = self.initializer()
                elif self.at("{"):
                    init = self.initializer()
                if not is_static:
                    sd.fields.append((ftype, fname, line, dims, init, is_ptr))
                else:
                    sd.statics.append((ftype, fname, init))         # one shared value: a global
                if not self.accept(","):
                    break
            self.expect(";")
        end = self.expect("}")
        self.accept(";")
        sd.end_line = end.line
        sd.src = self.src(start)
        return sd

    def func_rest(self, name: str, ret: str, start: Tok, owner: str = "", ctor: bool = False) -> FuncDef:
        f = self._func_rest(name, ret, start, owner, ctor)
        f.defaults = self._defaults
        return f

    def _func_rest(self, name: str, ret: str, start: Tok, owner: str = "", ctor: bool = False) -> FuncDef:
        self.expect("(")
        params = []
        defaults = self._defaults = {}
        while not self.at(")"):
            if self.at("void") and self.at(")", 1):
                self.next()
                break
            ptype, _ = self.parse_type()
            by_ref = is_ptr = False
            while self.at("*") or self.at("&"):
                if self.peek().val == "&":
                    by_ref = True
                else:
                    is_ptr = True
                self.next()
            pname = self.next().val if self.peek().kind == "id" else f"arg{len(params)}"
            is_array = False
            while self.accept("["):
                is_array = True
                while not self.at("]"):
                    self.next()
                self.expect("]")
            if self.accept("="):                                 # int depth = 0
                defaults[len(params)] = self.assign_expr()
            params.append((ptype, pname, is_array, by_ref, is_ptr))
            if not self.accept(","):
                break
        self.expect(")")
        while self.peek().val in ("const", "override", "noexcept", "final"):
            self.next()
        inits = []
        if ctor and self.accept(":"):
            while True:
                fname = self.next().val
                if self.at("("):
                    self.next()
                    args = []
                    while not self.at(")"):
                        args.append(self.assign_expr())
                        if not self.accept(","):
                            break
                    self.expect(")")
                else:
                    init = self.initializer()
                    args = init.items if isinstance(init, InitList) else [init]
                inits.append((fname, args))
                if not self.accept(","):
                    break
        if self.accept(";"):                                    # a prototype
            return FuncDef(start.line, "", ret, name, params, None, start.line, inits, owner)
        if self.at("=") :                                      # = default; = delete;
            while not self.at(";"):
                self.next()
            self.next()
            return FuncDef(start.line, "", ret, name, params, Block(start.line, "", []), start.line, inits, owner)
        line = self.peek().line
        body = self.block()
        return FuncDef(line, "", ret, name, params, body, self.toks[self.i - 1].line, inits, owner)

    def func_def(self) -> FuncDef:
        start = self.peek()
        ret, _ = self.parse_type()
        while self.at("*") or self.at("&"):
            self.next()
        name = self.next().val
        owner = ""
        if self.accept("::"):                                   # Type Class::method(...) defined outside
            owner, name = name, self.next().val
        f = self.func_rest(name, ret, start, owner, ctor=False)
        f.line = start.line
        return f

    # statements
    def block(self) -> Block:
        start = self.expect("{")
        body = []
        while not self.at("}"):
            if self.peek().kind == "eof":
                raise CppError("unclosed block")
            body.append(self.statement())
        self.expect("}")
        return Block(start.line, self.src(start), body)

    def statement(self) -> Node:
        t = self.peek()
        if self.at("{"):
            return self.block()
        if self.at("if"):
            self.next()
            self.expect("(")
            cond = self.expr()
            self.expect(")")
            then = self.statement()
            other = self.statement() if self.accept("else") else None
            return If(t.line, self.src(t), cond, then, other)
        if self.at("for"):
            self.next()
            self.expect("(")
            save = self.i
            if self.is_type_start():                             # range-for: for (T x : seq)
                vtype, _ = self.parse_type()
                by_ref = False
                while self.at("&") or self.at("*"):
                    by_ref = by_ref or self.peek().val == "&"
                    self.next()
                if self.peek().kind == "id" and self.at(":", 1):
                    name = self.next().val
                    self.next()
                    seq = self.expr()
                    self.expect(")")
                    body = self.statement()
                    return RangeFor(t.line, self.src(t), vtype, name, by_ref, seq, body, self.toks[self.i - 1].line)
                self.i = save
            init = None if self.at(";") else (self.var_decl(end=False) if self.is_type_start() else
                                              ExprStmt(self.peek().line, "", self.expr()))
            self.expect(";")
            cond = None if self.at(";") else self.expr()
            self.expect(";")
            step = None if self.at(")") else self.expr()
            self.expect(")")
            body = self.statement()
            return For(t.line, self.src(t), init, cond, step, body, self.toks[self.i - 1].line)
        if self.at("while"):
            self.next()
            self.expect("(")
            cond = self.expr()
            self.expect(")")
            body = self.statement()
            return While(t.line, self.src(t), cond, body, False, self.toks[self.i - 1].line)
        if self.at("do"):
            self.next()
            body = self.statement()
            self.expect("while")
            self.expect("(")
            cond = self.expr()
            self.expect(")")
            self.expect(";")
            return While(t.line, self.src(t), cond, body, True, self.toks[self.i - 1].line)
        if self.at("switch"):
            self.next()
            self.expect("(")
            subject = self.expr()
            self.expect(")")
            self.expect("{")
            cases = []                                           # [(label expr | None for default, [stmts])]
            while not self.at("}"):
                if self.accept("case"):
                    label = self.expr()
                    self.expect(":")
                    cases.append((label, []))
                elif self.at("default") and self.at(":", 1):
                    self.next()
                    self.next()
                    cases.append((None, []))
                elif not cases:
                    raise CppError(f"line {self.peek().line}: statement before the first case")
                else:
                    cases[-1][1].append(self.statement())
            self.expect("}")
            return Switch(t.line, self.src(t), subject, cases, self.toks[self.i - 1].line)
        if self.at("break") or self.at("continue"):
            self.next()
            self.expect(";")
            return Jump(t.line, t.val, t.val)
        if self.at("return"):
            self.next()
            value = None if self.at(";") else self.expr()
            self.expect(";")
            return Jump(t.line, self.src(t), "return", value)
        if self.at("delete"):
            self.next()
            if self.at("["):
                self.next()
                self.expect("]")
            e = self.expr()
            self.expect(";")
            return Delete(t.line, self.src(t), e)
        if self.at(";"):
            self.next()
            return Block(t.line, "", [])
        if (self.at("struct") or self.at("class")) and (self.at("{", 2) or self.at("{", 1)):
            return self.struct_def()
        if self.at("enum"):
            return self.enum_def()
        if self.is_type_start() and self.looks_like_decl():
            return self.var_decl()
        e = self.expr()
        self.expect(";")
        return ExprStmt(t.line, self.src(t), e)

    def looks_like_decl(self) -> bool:
        save = self.i
        try:
            self.parse_type()
            while self.at("*") or self.at("&"):
                self.next()
            return self.peek().kind == "id" and not self.at("(", 1) or (
                self.peek().kind == "id" and self.at("(", 1) and self.peek().val not in self.types)
        except CppError:
            return False
        finally:
            self.i = save

    def var_decl(self, end: bool = True) -> VarDecl:
        t = self.peek()
        vtype, const = self.parse_type()
        decls = []
        while True:
            is_ptr = is_ref = False
            while self.at("*") or self.at("&"):
                if self.peek().val == "*":
                    is_ptr = True
                else:
                    is_ref = True
                self.next()
            name = self.next().val
            dims = []
            while self.accept("["):
                dims.append(None if self.at("]") else self.expr())
                self.expect("]")
            init = None
            if self.accept("="):
                init = self.initializer()
            elif self.at("{"):
                init = self.initializer()
            elif self.at("("):
                p = self.next()
                args = []
                while not self.at(")"):
                    args.append(self.assign_expr())
                    if not self.accept(","):
                        break
                self.expect(")")
                init = InitList(p.line, "ctor", args)
            decls.append((name, dims, init, is_ptr, is_ref))
            if not self.accept(","):
                break
        if end:
            self.expect(";")
        return VarDecl(t.line, self.src(t), vtype, decls, const)

    def initializer(self) -> Node:
        if self.at("{"):
            t = self.next()
            items = []
            while not self.at("}"):
                items.append(self.initializer())
                if not self.accept(","):
                    break
            self.expect("}")
            return InitList(t.line, self.src(t), items)
        return self.assign_expr()

    # expressions (C++ precedence)
    def expr(self) -> Node:
        t = self.peek()
        e = self.assign_expr()
        while self.at(","):
            self.next()
            e2 = self.assign_expr()
            e = Binary(t.line, self.src(t), ",", e, e2)
        return e

    def assign_expr(self) -> Node:
        t = self.peek()
        left = self.ternary()
        if self.peek().kind == "op" and self.peek().val in ("=", "+=", "-=", "*=", "/=", "%="):
            op = self.next().val
            right = self.initializer() if self.at("{") else self.assign_expr()
            return Assign(t.line, self.src(t), op, left, right)
        return left

    def ternary(self) -> Node:
        t = self.peek()
        c = self.binary(0)
        if self.accept("?"):
            a = self.assign_expr()
            self.expect(":")
            b = self.assign_expr()
            return Ternary(t.line, self.src(t), c, a, b)
        return c

    LEVELS = [("||",), ("&&",), ("|",), ("^",), ("&",), ("==", "!="), ("<", "<=", ">", ">="), ("<<", ">>"),
              ("+", "-"), ("*", "/", "%")]

    def binary(self, level: int) -> Node:
        if level == len(self.LEVELS):
            return self.unary()
        t = self.peek()
        left = self.binary(level + 1)
        while self.peek().kind == "op" and self.peek().val in self.LEVELS[level]:
            op = self.next().val
            right = self.binary(level + 1)
            left = Binary(t.line, self.src(t), op, left, right)
        return left

    def unary(self) -> Node:
        t = self.peek()
        if t.kind == "op" and t.val in ("-", "+", "!", "++", "--", "*", "&", "~"):
            self.next()
            e = self.unary()
            return Unary(t.line, self.src(t), t.val, e)
        if self.at("new"):
            self.next()
            ntype, _ = self.parse_type()
            while self.at("*"):
                self.next()
                ntype += "*"
            args = None
            count = None
            if self.at("["):
                self.next()
                count = self.expr()
                self.expect("]")
            if self.at("{") or self.at("("):
                closing = "}" if self.at("{") else ")"
                self.next()
                args = []
                while not self.at(closing):
                    args.append(self.initializer())
                    if not self.accept(","):
                        break
                self.expect(closing)
            return New(t.line, self.src(t), ntype, args, count)
        if self.peek().val in ("static_cast", "dynamic_cast", "reinterpret_cast", "const_cast") and self.at("<", 1):
            self.next()
            self.next()
            ctype, _ = self.parse_type()
            while self.at("*"):
                self.next()
            self.expect(">")
            self.expect("(")
            e = self.expr()
            self.expect(")")
            return Cast(t.line, self.src(t), ctype, e)
        if self.at("sizeof"):
            self.next()
            self.skip_balanced("(", ")")
            return Lit(t.line, "sizeof", 4)
        if self.at("(") and self.is_type_start(1) and (self.at(")", 2) or self.at("*", 2)):   # (int) x
            self.next()
            ctype, _ = self.parse_type()
            while self.at("*"):
                self.next()
            self.expect(")")
            e = self.unary()
            return Cast(t.line, self.src(t), ctype, e)
        return self.postfix()

    def postfix(self) -> Node:
        t = self.peek()
        e = self.primary()
        while True:
            if self.at(".") or self.at("->"):
                arrow = self.next().val == "->"
                e = Member(t.line, "", e, self.next().val, arrow)
            elif self.accept("["):
                idx = self.expr()
                self.expect("]")
                e = Index(t.line, "", e, idx)
            elif self.at("(") and isinstance(e, (Name, Member)):
                self.next()
                args = []
                while not self.at(")"):
                    args.append(self.initializer() if self.at("{") else self.assign_expr())
                    if not self.accept(","):
                        break
                self.expect(")")
                e = Call(t.line, "", e, args)
            elif self.peek().kind == "op" and self.peek().val in ("++", "--"):
                op = self.next().val
                e = Unary(t.line, "", op, e, True)
            else:
                break
            e.src = self.src(t)
        return e

    def primary(self) -> Node:
        t = self.next()
        if t.kind == "num":
            v = t.val.rstrip("uUlLfF")
            if v.lower().startswith("0x"):
                return Lit(t.line, t.val, int(v, 16))
            return Lit(t.line, t.val, float(v) if ("." in v or "e" in v.lower()) else int(v))
        if t.kind == "str":
            s = unescape(t.val[1:-1])
            while self.peek().kind == "str":
                s += unescape(self.next().val[1:-1])
            return Lit(t.line, t.val, s)
        if t.kind == "chr":
            return Lit(t.line, t.val, Char(unescape(t.val[1:-1])))
        if t.kind == "id":
            if t.val in ("true", "false"):
                return Lit(t.line, t.val, t.val == "true")
            if t.val in ("nullptr", "NULL"):
                return Lit(t.line, t.val, NULL)
            name = t.val
            while self.at("::"):
                self.next()
                name = self.next().val                          # std::cout -> cout, Node::live -> live
            if name in ("greater", "less") and self.at("<"):    # greater<int>() for sort
                depth = 0
                while True:
                    v = self.next().val
                    depth += {"<": 1, ">": -1, ">>": -2}.get(v, 0)
                    if depth <= 0:
                        break
                if self.accept("("):
                    self.expect(")")
                return Lit(t.line, name, Comparator(name))
            if name in self.types and self.at("{"):             # Student{1001, "Amina"}: a temporary
                init = self.initializer()
                return Cast(t.line, self.src(t), name, init)
            return Name(t.line, name, name)
        if t.val == "(":
            e = self.expr()
            self.expect(")")
            return e
        if t.val == "{":
            self.i -= 1
            return self.initializer()
        raise CppError(f"line {t.line}: unexpected {t.val!r}")


# ------------------------------------------------------------------- values

class Char(str):
    pass


class Box:
    """One cell of memory. Variables, fields, elements and heap nodes are boxes."""
    __slots__ = ("value", "path", "type")

    def __init__(self, value=None, path: tuple = (), vtype: str = ""):
        self.value = value
        self.path = path
        self.type = vtype


@dataclass
class Struct:
    type: str
    fields: dict              # name -> Box


@dataclass
class Array:
    elem: str
    items: list               # [Box]
    kind: str = "array"       # array | vector | queue | stack


class Ptr:
    """A pointer: the box it points at (None for nullptr), and where that box sits in an array."""
    __slots__ = ("box", "array", "index")

    def __init__(self, box: Box | None, array: Array | None = None, index: int = 0):
        self.box = box
        self.array = array
        self.index = index

    def __eq__(self, other):
        if isinstance(other, Ptr):
            return self.box is other.box
        if other is None:
            return self.box is None
        return False

    def __bool__(self):
        return self.box is not None


NULL = Ptr(None)


class Cout:
    pass


ALGORITHMS = {"sort", "stable_sort", "reverse", "fill", "iota", "is_sorted", "accumulate", "count", "find",
              "min_element", "max_element"}

LIMITS = {"INT_MAX": 2147483647, "INT_MIN": -2147483648, "LONG_MAX": 2147483647, "LONG_MIN": -2147483648,
          "LLONG_MAX": 9223372036854775807,
          "LLONG_MIN": -9223372036854775808, "UINT_MAX": 4294967295, "SIZE_MAX": 18446744073709551615}
CTYPE = {"isalnum": str.isalnum, "isalpha": str.isalpha, "isdigit": str.isdigit, "isspace": str.isspace,
         "isupper": str.isupper, "islower": str.islower, "ispunct": lambda c: not c.isalnum() and c.isprintable()
         and not c.isspace(), "toupper": str.upper, "tolower": str.lower}


class Comparator:
    """greater<int>() / less<int>() passed to sort."""

    def __init__(self, kind: str):
        self.kind = kind


def ctors_of(sd, name: str) -> list:
    return [m for m in sd.methods.get(name, []) if m.body is not None]


def path_text(path) -> str:
    if not path:
        return "?"
    out = str(path[0])
    for p in path[1:]:
        out += f"[{p}]" if isinstance(p, int) else f".{p}"
    return out


def snap(v):
    """A JSON-friendly snapshot of a value."""
    if isinstance(v, Box):
        v = v.value
    if isinstance(v, Ptr):
        return {"ptr": path_text(v.box.path) if v.box is not None else None}
    if isinstance(v, Struct):
        return {"struct": v.type, "fields": {k: snap(b) for k, b in v.fields.items()}}
    if isinstance(v, Array):
        return {"array": v.elem, "kind": v.kind, "items": [snap(b) for b in v.items]}
    if isinstance(v, Char):
        return {"char": str(v)}
    if isinstance(v, float):
        return round(v, 6)
    if isinstance(v, (Cout,)):
        return None
    return v


def show(v) -> str:
    """How a value is written on screen."""
    if isinstance(v, dict) and "char" in v:
        return "'" + v["char"].replace("\n", "\\n") + "'"
    if isinstance(v, dict) and "ptr" in v:
        return "nullptr" if v["ptr"] is None else "&" + v["ptr"]
    if isinstance(v, Char):
        return "'" + str(v).replace("\n", "\\n") + "'"
    if v is None:
        return "?"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, float):
        return f"{v:g}"
    if isinstance(v, str):
        return '"' + v + '"'
    if isinstance(v, dict) and "struct" in v:
        return v["struct"]
    if isinstance(v, dict) and "array" in v:
        return f"{v['array']}[{len(v['items'])}]"
    return str(v)


def speak(v, heap: dict | None = None) -> str:
    """How a value is read aloud."""
    if isinstance(v, dict) and "char" in v:
        return {"\n": "a new line", " ": "a space"}.get(v["char"], v["char"])
    if isinstance(v, dict) and "ptr" in v:
        if v["ptr"] is None:
            return "null"
        return "the node holding " + node_label(v["ptr"], heap) if heap and v["ptr"] in heap else v["ptr"]
    if isinstance(v, bool):
        return "true" if v else "false"
    if v is None:
        return "nothing yet"
    if isinstance(v, float):
        return f"{v:g}"
    return str(v)


def node_label(ref: str, heap: dict | None) -> str:
    """A heap node named by its first non-pointer field: 'the node holding 12'."""
    node = (heap or {}).get(ref)
    if isinstance(node, dict) and "fields" in node:
        for val in node["fields"].values():
            if not (isinstance(val, dict) and "ptr" in val):
                return speak(val)
    return ref


# --------------------------------------------------------------- interpreter

class _Break(Exception):
    pass


class _Continue(Exception):
    pass


class _Return(Exception):
    def __init__(self, value):
        self.value = value


class Interpreter:
    """Runs listings one after another, sharing globals, types and functions."""

    def __init__(self):
        self.globals: dict[str, Box] = {}
        self.structs: dict[str, StructDef] = {}
        self.funcs: dict[str, list[FuncDef]] = {}
        self.heap: dict[str, Box] = {}
        self.heap_count = 0
        self.events: list[dict] = []
        self.steps = 0
        self.frames: list[dict] = []           # local scopes of the running function: [ {name: Box} ]
        self.this: list[Box | None] = [None]
        self.depth = 0
        self.block_depth = 0
        self.fmt = {"width": 0, "fixed": False, "precision": 6}

    # -------------------------------------------------------------- running

    def run(self, code: str, call_main: bool = True) -> list[dict]:
        """Run one listing; return its events. Raises CppError outside the subset."""
        parser = Parser(code, set(self.structs))
        items = parser.program()
        self.events = []
        self.steps = 0
        self.frames = [{}]
        self.this = [None]
        saved = (copy.copy(self.globals), dict(self.structs), dict(self.funcs), dict(self.heap), self.heap_count)
        try:
            ran_statement = False                      # a fragment with loose statements never calls main
            defines_main = any(isinstance(i, FuncDef) and i.name == "main" for i in items)
            for item in items:
                if not isinstance(item, (StructDef, FuncDef, EnumDef, VarDecl)):
                    ran_statement = True
                self.top(item)
            if call_main and not ran_statement and defines_main:
                self.call_function(self.funcs["main"][0], [], 0)
        except (_Break, _Continue, _Return):
            pass
        except CppError:
            self.globals, self.structs, self.funcs, self.heap, self.heap_count = saved
            raise
        except RecursionError as exc:
            self.globals, self.structs, self.funcs, self.heap, self.heap_count = saved
            raise CppError("recursion too deep to animate") from exc
        except (TypeError, ValueError, KeyError, IndexError, ZeroDivisionError, AttributeError) as exc:
            self.globals, self.structs, self.funcs, self.heap, self.heap_count = saved
            raise CppError(f"cannot run: {exc}") from exc
        self._close_print()
        return self.events

    def emit(self, event: str, line: int, **data) -> None:
        self.steps += 1
        if self.steps > MAX_STEPS:
            raise CppError("too many steps to animate")
        last = self.events[-1] if self.events else None
        if event == "print" and last and last["k"] == "print" and not last.get("closed"):
            last["text"] += data["text"]
            last["end"] = line
            return
        self._close_print()
        self.events.append({"k": event, "line": line, **data})

    def _close_print(self) -> None:
        if self.events and self.events[-1]["k"] == "print":
            self.events[-1]["closed"] = True

    def top(self, item: Node) -> None:
        if isinstance(item, StructDef):
            self.define_struct(item)
        elif isinstance(item, EnumDef):
            self.define_enum(item)
        elif isinstance(item, FuncDef):
            if item.owner:
                sd = self.structs.get(item.owner)
                if sd is not None:
                    sd.methods.setdefault(item.name, []).append(item)
                return
            if item.body is not None:
                self.funcs.setdefault(item.name, []).insert(0, item)
                self.emit("func", item.line, name=item.name, end=item.end_line,
                          params=[[t, n] for t, n, *_ in item.params], ret=item.ret)
        else:
            self.exec(item)

    def define_enum(self, ed: EnumDef) -> None:
        nxt = 0
        for name, expr in ed.values:
            value = int(self.value(self.eval(expr))) if expr is not None else nxt
            self.globals[name] = Box(value, (name,), "int")
            nxt = value + 1

    def define_struct(self, sd: StructDef) -> None:
        self.structs[sd.name] = sd
        for stype, sname, sinit in sd.statics:
            if sname not in self.globals:
                value = self.convert(stype, [], self.eval_init(sinit), (sname,)) if sinit is not None else \
                    self.default(stype, [], (sname,))
                self.globals[sname] = Box(0 if value is None else value, (sname,), stype)
        self.emit("struct", sd.line, name=sd.name, end=sd.end_line,
                  fields=[[t + ("*" if p else ""), n] for t, n, _, _, _, p in sd.fields],
                  methods=sorted(sd.methods))
        for k, (t, n, line, _, _, is_ptr) in enumerate(sd.fields):
            self.emit("field", line, struct=sd.name, index=k, type=t + ("*" if is_ptr else ""), name=n)

    # ------------------------------------------------------------ variables

    def lookup(self, name: str) -> Box:
        if name == "this" and self.this[-1] is not None:
            return Box(Ptr(self.this[-1]), ("this",), "")
        frame = self.frames[-1]
        if name in frame:
            return frame[name]
        this = self.this[-1]
        if this is not None and isinstance(this.value, Struct) and name in this.value.fields:
            return this.value.fields[name]
        if name in self.globals:
            return self.globals[name]
        if name in LIMITS:
            return Box(LIMITS[name], (name,), "int")
        raise CppError(f"unknown name {name}")

    def base_type(self, t: str) -> str:
        return (t or "").replace("const ", "").strip()

    def container_of(self, t: str) -> tuple[str, str] | None:
        m = re.match(r"(vector|queue|stack|deque|list)<(.+)>$", self.base_type(t))
        return (m.group(1), m.group(2).strip()) if m else None

    def default(self, vtype: str, dims: list, path: tuple, is_ptr: bool = False):
        if is_ptr:
            return NULL
        if dims:
            n = dims[0] or 0
            items = [Box(self.default(vtype, dims[1:], path + (k,)), path + (k,), vtype) for k in range(n)]
            return Array(vtype, items)
        cont = self.container_of(vtype)
        if cont:
            kind = "vector" if cont[0] in ("vector", "deque", "list") else cont[0]
            return Array(cont[1], [], kind)
        if vtype.endswith("*"):
            return NULL
        if vtype in self.structs:
            return self.make_struct(vtype, [], path, ctor_args=None, use_ctor=True)
        if self.base_type(vtype) == "string":
            return ""
        return None

    def make_struct(self, vtype: str, items: list, path: tuple, ctor_args=None, use_ctor: bool = False):
        sd = self.structs[vtype]
        fields = {}
        for k, (ftype, fname, _, fdims, finit, is_ptr) in enumerate(sd.fields):
            fpath = path + (fname,)
            dims = [int(self.value(self.eval(d))) if d is not None else 0 for d in fdims]
            if k < len(items) and ctor_args is None and not ctors_of(sd, vtype):
                val = self.convert(ftype, dims, items[k], fpath, is_ptr)
            elif finit is not None:
                val = self.convert(ftype, dims, self.eval_init(finit), fpath, is_ptr)
            else:
                val = self.default(ftype, dims, fpath, is_ptr)
            fields[fname] = Box(val, fpath, ftype + ("*" if is_ptr else ""))
        obj = Struct(vtype, fields)
        ctors = [m for m in sd.methods.get(vtype, []) if m.body is not None]
        if ctors and (ctor_args is not None or use_ctor or items):
            args = ctor_args if ctor_args is not None else items
            ctor = self.pick(ctors, len(args), strict=True)
            if ctor is not None:
                holder = Box(obj, path, vtype)
                self.call_function(ctor, args, ctor.line, this=holder, evaluated=True)
                obj = holder.value
        return obj

    def convert(self, vtype: str, dims: list, value, path: tuple, is_ptr: bool = False):
        """A value made to fit a declared type (with fresh boxes for aggregates)."""
        if isinstance(value, Box):
            value = value.value
        if is_ptr or (vtype or "").endswith("*"):
            if isinstance(value, Ptr):
                return value
            if isinstance(value, Array):                          # an array decays to a pointer to its first element
                return Ptr(value.items[0] if value.items else None, value, 0)
            if value is None or value == 0:
                return NULL
            return value
        if dims:
            items = value if isinstance(value, list) else (value.items if isinstance(value, Array) else [])
            n = dims[0] if dims[0] else len(items)
            out = []
            for k in range(n):
                if k < len(items):
                    out.append(Box(self.convert(vtype, dims[1:], items[k], path + (k,)), path + (k,), vtype))
                elif items and not dims[1:] and vtype not in self.structs:
                    out.append(Box(0, path + (k,), vtype))
                else:
                    out.append(Box(self.default(vtype, dims[1:], path + (k,)), path + (k,), vtype))
            return Array(vtype, out)
        cont = self.container_of(vtype)
        if cont:
            kind = "vector" if cont[0] in ("vector", "deque", "list") else cont[0]
            src = value.items if isinstance(value, Array) else (value if isinstance(value, list) else [])
            return Array(cont[1], [Box(self.convert(cont[1], [], b, path + (k,)), path + (k,), cont[1])
                                   for k, b in enumerate(src)], kind)
        if vtype in self.structs:
            if isinstance(value, Struct):
                return self.copy_struct(value, path)
            items = value if isinstance(value, list) else ([] if value is None else [value])
            return self.make_struct(vtype, items, path)
        if isinstance(value, list):
            value = value[0] if value else None
        if value is None:
            return None
        base = self.base_type(vtype).split()[-1] if vtype else ""
        if base in ("int", "long", "short", "size_t", "unsigned") and isinstance(value, (int, float)) \
                and not isinstance(value, bool):
            return int(value)
        if base in ("double", "float") and isinstance(value, (int, float)) and not isinstance(value, bool):
            return float(value)
        if base == "bool":
            return bool(value) if not isinstance(value, Ptr) else bool(value)
        if base == "char" and isinstance(value, int) and not isinstance(value, bool):
            return Char(chr(value))
        if base == "string" and isinstance(value, Char):
            return str(value)
        return value

    def copy_struct(self, s: Struct, path: tuple) -> Struct:
        fields = {}
        for name, box in s.fields.items():
            fields[name] = Box(self.copy_value(box.value, path + (name,)), path + (name,), box.type)
        return Struct(s.type, fields)

    def copy_value(self, v, path: tuple):
        if isinstance(v, Struct):
            return self.copy_struct(v, path)
        if isinstance(v, Array):
            return Array(v.elem, [Box(self.copy_value(b.value, path + (k,)), path + (k,), b.type)
                                  for k, b in enumerate(v.items)], v.kind)
        return v

    def rebase(self, v, path: tuple):
        """Give an aggregate (and everything inside it) the paths of its new home."""
        if isinstance(v, Struct):
            for name, box in v.fields.items():
                box.path = path + (name,)
                self.rebase(box.value, box.path)
        elif isinstance(v, Array):
            for k, box in enumerate(v.items):
                box.path = path + (k,)
                self.rebase(box.value, box.path)
        return v

    # ------------------------------------------------------------ statements

    def exec(self, node: Node) -> None:
        self.steps += 1
        if self.steps > MAX_STEPS:
            raise CppError("too many steps to animate")
        if isinstance(node, Block):
            # names declared in the block go out of scope; outer names are the same cells, so changes stay
            outer = self.frames[-1]
            self.frames[-1] = dict(outer)
            self.block_depth += 1
            try:
                for s in node.body:
                    self.exec(s)
            finally:
                self.frames[-1] = outer
                self.block_depth -= 1
        elif isinstance(node, VarDecl):
            for name, dim_exprs, init, is_ptr, is_ref in node.decls:
                dims = [None if d is None else int(self.value(self.eval(d))) for d in dim_exprs]
                path = (name,)
                if is_ref and init is not None:                         # int& r = x;  an alias
                    target = self.box_of(init)
                    self.frames[-1][name] = target
                    continue
                if isinstance(init, InitList) and init.src == "ctor" and node.type in self.structs and not dims:
                    args = [self.eval(a) for a in init.items]
                    value = self.make_struct(node.type, [], path, ctor_args=args)
                elif isinstance(init, InitList) and init.src == "ctor" and self.container_of(node.type):
                    args = [self.value(self.eval(a)) for a in init.items]       # vector<int> v(n, 0)
                    n = int(args[0]) if args else 0
                    cont = self.container_of(node.type)
                    value = Array(cont[1], [Box(self.copy_value(args[1], path + (k,)) if len(args) > 1
                                                else self.default(cont[1], [], path + (k,)), path + (k,), cont[1])
                                            for k in range(n)], "vector")
                else:
                    raw = self.eval_init(init) if init is not None else None
                    if dims and None in dims:
                        n = len(raw) if isinstance(raw, list) else 0
                        dims = [n if d is None else d for d in dims]
                    if init is not None:
                        value = self.convert(node.type, dims, raw, path, is_ptr)
                    else:
                        value = self.default(node.type, dims, path, is_ptr)
                vtype = node.type + ("*" if is_ptr else "")
                box = Box(value, path, vtype)
                self.rebase(value, path)
                if len(self.frames) == 1 and self.this[-1] is None and self.block_depth == 0:
                    self.globals[name] = box
                    scope = "global"
                else:
                    scope = "local"
                self.frames[-1][name] = box
                self.emit("decl", node.line, name=name, type=vtype, dims=dims, const=node.const,
                          value=snap(value), scope=scope, depth=self.depth)
        elif isinstance(node, ExprStmt):
            self._close_print()
            self.eval(node.expr)
        elif isinstance(node, If):
            if self.cond(node.cond, node.line, "if"):
                self.exec(node.then)
            elif node.other is not None:
                self.exec(node.other)
        elif isinstance(node, For):
            saved = self.frames[-1]
            self.frames[-1] = dict(saved)
            self.block_depth += 1
            try:
                loop_var = None
                if node.init is not None:
                    if isinstance(node.init, VarDecl):
                        loop_var = node.init.decls[0][0]
                        self.exec(node.init)
                    else:
                        self.eval(node.init.expr)
                        if isinstance(node.init.expr, Assign) and isinstance(node.init.expr.target, Name):
                            loop_var = node.init.expr.target.id
                while True:
                    if loop_var:
                        self.emit("loop", node.line, var=loop_var, value=snap(self.lookup(loop_var)),
                                  end=node.end_line)
                    if node.cond is not None and not self.cond(node.cond, node.line, "loop"):
                        self.emit("loopend", node.line, end=node.end_line)
                        break
                    try:
                        self.exec(node.body)
                    except _Break:
                        break
                    except _Continue:
                        pass
                    if node.step is not None:
                        before = len(self.events)
                        self.eval(node.step)
                        for e in self.events[before:]:
                            if e["k"] == "assign":
                                e["step"] = True                   # the loop moving on
            finally:
                self.frames[-1] = saved
                self.block_depth -= 1
        elif isinstance(node, RangeFor):
            seq = self.value(self.eval(node.seq))
            if isinstance(seq, Array):
                items = seq.items
            elif isinstance(seq, str):
                items = [Box(Char(c)) for c in seq]
            elif isinstance(seq, list):                          # for (int v : {10, 20, 30})
                items = [Box(v) for v in seq]
            else:
                raise CppError(f"line {node.line}: cannot loop over that")
            saved = self.frames[-1]
            self.frames[-1] = dict(saved)
            self.block_depth += 1
            try:
                for k, item in enumerate(list(items)):
                    if node.by_ref:
                        self.frames[-1][node.name] = item
                    else:
                        self.frames[-1][node.name] = Box(self.copy_value(item.value, (node.name,)), (node.name,),
                                                         node.type)
                    self.emit("loop", node.line, var=node.name, value=snap(item.value), index=k,
                              seq=list(item.path[:-1]) if item.path else None, end=node.end_line)
                    try:
                        self.exec(node.body)
                    except _Break:
                        break
                    except _Continue:
                        pass
                else:
                    self.emit("loopend", node.line, end=node.end_line)
            finally:
                self.frames[-1] = saved
                self.block_depth -= 1
        elif isinstance(node, While):
            first = node.do
            while True:
                if not first and not self.cond(node.cond, node.line, "loop"):
                    self.emit("loopend", node.line, end=node.end_line)
                    break
                first = False
                try:
                    self.exec(node.body)
                except _Break:
                    break
                except _Continue:
                    pass
        elif isinstance(node, Switch):
            value = self.value(self.eval(node.subject))
            start = next((k for k, (label, _) in enumerate(node.cases)
                          if label is not None and self.value(self.eval(label)) == value), None)
            if start is None:
                start = next((k for k, (label, _) in enumerate(node.cases) if label is None), len(node.cases))
            try:
                for _, stmts in node.cases[start:]:                      # falls through until a break
                    for stmt in stmts:
                        self.exec(stmt)
            except _Break:
                if self.events and self.events[-1]["k"] == "break":   # leaving a switch is not a loop break
                    self.events.pop()
        elif isinstance(node, Jump):
            if node.kind == "break":
                self.emit("break", node.line)
                raise _Break()
            if node.kind == "continue":
                raise _Continue()
            value = self.eval(node.value) if node.value is not None else None
            if isinstance(value, Box):
                value = value.value
            self.emit("return", node.line, value=snap(value), depth=self.depth)
            raise _Return(value)
        elif isinstance(node, Delete):
            p = self.value(self.eval(node.expr))
            if isinstance(p, Ptr) and p.box is not None:
                ref = path_text(p.box.path)
                if ref in self.heap:
                    del self.heap[ref]
                self.emit("delete", node.line, id=ref, src=node.src)
                if isinstance(p.box.value, Struct):
                    self.run_hook(p.box.value.type, "delete")
        elif isinstance(node, StructDef):
            self.define_struct(node)
        elif isinstance(node, EnumDef):
            self.define_enum(node)
        elif isinstance(node, FuncDef):
            self.top(node)
        else:
            raise CppError(f"cannot run {type(node).__name__}")

    def cond(self, expr: Node, line: int, kind: str) -> bool:
        detail = {}
        if isinstance(expr, Binary) and expr.op in ("==", "!=", "<", "<=", ">", ">="):
            lv, rv = self.value(self.eval(expr.left)), self.value(self.eval(expr.right))
            result = self.compare(expr.op, lv, rv)
            detail = {"op": expr.op, "left": self.side(expr.left, lv), "right": self.side(expr.right, rv)}
        else:
            result = bool(self.truthy(self.value(self.eval(expr))))
        self.emit("cond", line, kind=kind, src=expr.src, result=result, **detail)
        return result

    def side(self, node: Node, value) -> dict:
        out = {"value": snap(value), "src": node.src}
        try:
            box = self.box_of(node, quiet=True)
        except CppError:
            box = None
        if box is not None and box.path:
            out["path"] = list(box.path)
        return out

    # ----------------------------------------------------------- expressions

    @staticmethod
    def value(v):
        return v.value if isinstance(v, Box) else v

    @staticmethod
    def truthy(v) -> bool:
        if isinstance(v, (Struct, Array)):
            return True
        if isinstance(v, Ptr):
            return v.box is not None
        return bool(v)

    @staticmethod
    def compare(op: str, a, b) -> bool:
        if isinstance(a, Ptr) or isinstance(b, Ptr):
            same = (a == b) if isinstance(a, Ptr) else (b == a)
            if op == "==":
                return same
            if op == "!=":
                return not same
            raise CppError("pointer ordering is not animated")
        if isinstance(a, Array) and isinstance(b, Array):         # vectors compare element by element
            a = [snap(x) for x in a.items]
            b = [snap(x) for x in b.items]
        if isinstance(a, Char) and isinstance(b, int):
            a = ord(a)
        if isinstance(b, Char) and isinstance(a, int):
            b = ord(b)
        return {"==": a == b, "!=": a != b, "<": a < b, "<=": a <= b, ">": a > b, ">=": a >= b}[op]

    def eval_init(self, node: Node):
        if isinstance(node, InitList):
            return [self.eval_init(i) for i in node.items]
        v = self.eval(node)
        return v.value if isinstance(v, Box) else v

    def box_of(self, node: Node, quiet: bool = False) -> Box | None:
        """The memory cell an lvalue names."""
        if isinstance(node, Name):
            return self.lookup(node.id)
        if isinstance(node, Member):
            base = self.eval(node.obj)
            obj = self.value(base)
            if node.arrow or isinstance(obj, Ptr):
                if not isinstance(obj, Ptr):
                    raise CppError("-> needs a pointer")
                if obj.box is None:
                    raise CppError(f"line {node.line}: null pointer dereference")
                obj = obj.box.value
            if not isinstance(obj, Struct):
                raise CppError(f"no field {node.field}")
            if node.field not in obj.fields:
                raise CppError(f"no field {node.field}")
            return obj.fields[node.field]
        if isinstance(node, Index):
            base = self.value(self.eval(node.obj))
            idx = self.value(self.eval(node.index))
            if isinstance(base, Ptr) and base.array is not None:
                base, idx = base.array, base.index + int(idx)
            if isinstance(base, Array):
                k = int(idx)
                if not 0 <= k < len(base.items):
                    raise CppError(f"index {k} is outside the array")
                return base.items[k]
            if isinstance(base, str):
                return Box(Char(base[int(idx)]))
            raise CppError("cannot index that")
        if isinstance(node, Unary) and node.op == "*":
            p = self.value(self.eval(node.expr))
            if not isinstance(p, Ptr) or p.box is None:
                raise CppError("null pointer dereference")
            return p.box
        if quiet:
            return None
        raise CppError("not a variable")

    def store(self, box: Box, value, src_node: Node | None, line: int, step: bool = False) -> None:
        value = self.value(value)
        if isinstance(value, (Struct, Array)):
            value = self.copy_value(value, box.path)
            self.rebase(value, box.path)
        elif isinstance(value, list):
            value = self.convert(box.type, [], value, box.path)
        elif box.type:
            value = self.convert(box.type, [], value, box.path, box.type.endswith("*"))
        box.value = value
        data = {"path": list(box.path), "value": snap(value), "src": src_node.src if src_node else ""}
        if step:
            data["step"] = True
        self.emit("assign", line, **data)

    def eval(self, node: Node):
        self.steps += 1
        if self.steps > MAX_STEPS:
            raise CppError("too many steps to animate")
        if isinstance(node, Lit):
            return node.value
        if isinstance(node, Name):
            if node.id in ("cout", "cerr", "clog"):
                return Cout()
            if node.id == "endl":
                return "\n"
            if node.id in ("fixed", "boolalpha", "left", "right", "showpoint") and \
                    node.id not in self.frames[-1] and node.id not in self.globals:   # a variable named left wins
                if node.id == "fixed":
                    self.fmt["fixed"] = True
                return ""
            return self.lookup(node.id)
        if isinstance(node, (Member, Index)):
            return self.box_of(node)
        if isinstance(node, InitList):
            return self.eval_init(node)
        if isinstance(node, New):
            return self.new(node)
        if isinstance(node, Cast):
            inner = self.eval_init(node.expr) if isinstance(node.expr, InitList) else self.value(self.eval(node.expr))
            return self.convert(node.type, [], inner, ("tmp",))
        if isinstance(node, Assign):
            box = self.box_of(node.target)
            value = self.eval_init(node.value) if isinstance(node.value, InitList) else self.value(self.eval(node.value))
            if node.op != "=":
                if isinstance(box.value, str) and node.op == "+=":
                    value = box.value + self.text(value)
                else:
                    value = self.arith(node.op[0], box.value, value)
            self.store(box, value, node, node.line)
            return box
        if isinstance(node, Unary):
            if node.op in ("++", "--"):
                box = self.box_of(node.expr)
                old = box.value
                if isinstance(old, Ptr):
                    new = self.ptr_add(old, 1 if node.op == "++" else -1)
                else:
                    new = self.arith("+" if node.op == "++" else "-", old, 1)
                self.store(box, new, node, node.line)
                return old if node.postfix else box
            if node.op == "&":
                box = self.box_of(node.expr)
                arr, idx = self.array_position(box)
                return Ptr(box, arr, idx)
            if node.op == "*":
                return self.box_of(node)
            v = self.value(self.eval(node.expr))
            if node.op == "-":
                return -v
            if node.op == "+":
                return v
            if node.op == "!":
                return not self.truthy(v)
            if node.op == "~":
                return ~int(v)
        if isinstance(node, Binary):
            if node.op == "<<":
                left = self.value(self.eval(node.left))
                if isinstance(left, Cout):
                    if isinstance(node.right, Call) and isinstance(node.right.func, Name) and \
                            node.right.func.id in ("setw", "setprecision", "setfill"):
                        arg = self.value(self.eval(node.right.args[0])) if node.right.args else 0
                        if node.right.func.id == "setw":
                            self.fmt["width"] = int(arg)
                        elif node.right.func.id == "setprecision":
                            self.fmt["precision"] = int(arg)
                        return left
                    v = self.value(self.eval(node.right))
                    text = self.text(v)
                    if self.fmt["width"]:
                        text = text.rjust(self.fmt["width"])
                        self.fmt["width"] = 0
                    if text:
                        self.emit("print", node.line, text=text)
                    return left
                return int(left) << int(self.value(self.eval(node.right)))
            if node.op == ",":
                self.eval(node.left)
                return self.eval(node.right)
            if node.op == "&&":
                return self.truthy(self.value(self.eval(node.left))) and self.truthy(self.value(self.eval(node.right)))
            if node.op == "||":
                return self.truthy(self.value(self.eval(node.left))) or self.truthy(self.value(self.eval(node.right)))
            a, b = self.value(self.eval(node.left)), self.value(self.eval(node.right))
            if node.op in ("==", "!=", "<", "<=", ">", ">="):
                return self.compare(node.op, a, b)
            if isinstance(a, Array) and node.op in ("+", "-"):         # array name + k: a pointer
                return self.ptr_add(Ptr(a.items[0] if a.items else None, a, 0), b if node.op == "+" else -b)
            if isinstance(a, Ptr) and node.op in ("+", "-") and isinstance(b, int):
                return self.ptr_add(a, b if node.op == "+" else -b)
            if isinstance(a, str) and node.op == "+":
                return a + self.text(b)
            if isinstance(b, str) and node.op == "+" and isinstance(a, Char):
                return str(a) + b
            return self.arith(node.op, a, b)
        if isinstance(node, Ternary):
            return self.eval(node.a) if self.truthy(self.value(self.eval(node.cond))) else self.eval(node.b)
        if isinstance(node, Call):
            return self.call(node)
        raise CppError(f"cannot evaluate {type(node).__name__}")

    def array_position(self, box: Box):
        """If this box is an element of an array, (array, index)."""
        if len(box.path) >= 2 and isinstance(box.path[-1], int):
            try:
                parent = self.path_box(box.path[:-1])
            except CppError:
                return None, 0
            if parent is not None and isinstance(parent.value, Array):
                return parent.value, box.path[-1]
        return None, 0

    def path_box(self, path: tuple) -> Box | None:
        root = path[0]
        if isinstance(root, str) and root.startswith("#"):
            box = self.heap.get(root)
        else:
            try:
                box = self.lookup(root)
            except CppError:
                return None
        for p in path[1:]:
            v = box.value if box else None
            if isinstance(p, int) and isinstance(v, Array):
                box = v.items[p]
            elif isinstance(v, Struct):
                box = v.fields.get(p)
            else:
                return None
        return box

    def ptr_add(self, p: Ptr, k: int) -> Ptr:
        if p.array is None:
            raise CppError("pointer arithmetic outside an array")
        idx = p.index + int(k)
        box = p.array.items[idx] if 0 <= idx < len(p.array.items) else None
        return Ptr(box, p.array, idx)

    def run_hook(self, stype: str, hook: str) -> None:
        """A class's own operator new/delete body (a live-node counter), run around the allocation."""
        sd = self.structs.get(stype)
        for stmt in (sd.hooks.get(hook, []) if sd is not None else []):
            self.exec(stmt)

    def new(self, node: New):
        self.heap_count += 1
        ref = f"#{self.heap_count}"
        path = (ref,)
        ntype = node.type
        if node.count is not None:                                 # new T[n]
            n = int(self.value(self.eval(node.count)))
            value = Array(ntype, [Box(self.default(ntype, [], path + (k,)), path + (k,), ntype) for k in range(n)])
        elif ntype in self.structs:
            args = [self.eval_init(a) for a in (node.args or [])]
            sd = self.structs[ntype]
            self.run_hook(ntype, "new")
            ctors = [m for m in sd.methods.get(ntype, []) if m.body is not None]
            before = len(self.events)
            if ctors and node.args is not None:
                value = self.make_struct(ntype, [], path, ctor_args=args)
            else:
                value = self.make_struct(ntype, args, path, use_ctor=node.args is None)
            for e in self.events[before:]:
                e["ctor"] = True                                   # building the node: part of its new
        else:
            args = [self.eval_init(a) for a in (node.args or [])]
            value = self.convert(ntype, [], args[0] if args else None, path)
        box = Box(value, path, ntype)
        self.rebase(value, path)
        self.heap[ref] = box
        self.emit("new", node.line, id=ref, type=ntype, value=snap(value))
        arr = value if isinstance(value, Array) else None
        return Ptr(box if arr is None else (arr.items[0] if arr.items else None), arr, 0)

    def text(self, v) -> str:
        if isinstance(v, Box):
            v = v.value
        if isinstance(v, bool):
            return "1" if v else "0"
        if isinstance(v, float):
            if self.fmt["fixed"]:
                return f"{v:.{self.fmt['precision']}f}"
            return f"{v:.{self.fmt['precision']}g}"
        if isinstance(v, Ptr):
            return "0" if v.box is None else "0x" + format(abs(hash(path_text(v.box.path))) % 0xFFFFFF, "06x")
        if v is None:
            return "?"
        return str(v)

    @staticmethod
    def arith(op: str, a, b):
        if isinstance(a, Char):
            a = ord(a)
        if isinstance(b, Char):
            b = ord(b)
        if op == "+":
            return a + b
        if op == "-":
            return a - b
        if op == "*":
            return a * b
        if op == "/":
            if isinstance(a, int) and isinstance(b, int):
                if b == 0:
                    raise CppError("division by zero")
                q = abs(a) // abs(b)
                return q if (a >= 0) == (b >= 0) else -q
            return a / b
        if op == "%":
            if b == 0:
                raise CppError("division by zero")
            return a - b * int(a / b)
        if op == "&":
            return int(a) & int(b)
        if op == "|":
            return int(a) | int(b)
        if op == "^":
            return int(a) ^ int(b)
        if op == ">>":
            return int(a) >> int(b)
        raise CppError(f"cannot run operator {op}")

    # -------------------------------------------------------------- calls

    @staticmethod
    def pick(funcs: list[FuncDef], n: int, strict: bool = False) -> FuncDef | None:
        for f in funcs:
            if len(f.params) == n and f.body is not None:
                return f
        if strict:
            return None
        for f in funcs:
            if f.body is not None and len(f.params) >= n:
                return f
        return None

    def call(self, node: Call):
        f = node.func
        if isinstance(f, Member):                                     # a method
            obj_box = self.box_of(f.obj) if not f.arrow else None
            if f.arrow:
                p = self.value(self.eval(f.obj))
                if not isinstance(p, Ptr) or p.box is None:
                    raise CppError("method call through a null pointer")
                obj_box = p.box
            obj = obj_box.value
            if isinstance(obj, Array):
                return self.container_method(obj_box, f.field, node)
            if isinstance(obj, str):
                return self.string_method(obj_box, f.field, node)
            if isinstance(obj, Struct):
                methods = self.structs[obj.type].methods.get(f.field, [])
                m = self.pick(methods, len(node.args))
                if m is None:
                    raise CppError(f"no method {f.field}")
                args = self.bind_args(m, node.args)
                return self.call_function(m, args, node.line, this=obj_box, evaluated=True)
            raise CppError(f"cannot call {f.field}")
        name = f.id
        if name in ("max", "min") and len(node.args) == 2:
            a, b = self.value(self.eval(node.args[0])), self.value(self.eval(node.args[1]))
            return max(a, b) if name == "max" else min(a, b)
        if name in ("abs", "fabs") and len(node.args) == 1:
            return abs(self.value(self.eval(node.args[0])))
        if name == "sqrt":
            return float(self.value(self.eval(node.args[0]))) ** 0.5
        if name == "pow":
            return float(self.value(self.eval(node.args[0]))) ** float(self.value(self.eval(node.args[1])))
        if name == "swap" and len(node.args) == 2:
            a, b = self.box_of(node.args[0]), self.box_of(node.args[1])
            va, vb = a.value, b.value
            self.store(a, vb, node, node.line)
            self.store(b, va, node, node.line)
            return None
        if name == "printf":
            fmt = self.value(self.eval(node.args[0]))
            vals = [self.value(self.eval(a)) for a in node.args[1:]]
            self.emit("print", node.line, text=self.printf(fmt, vals))
            return None
        if name in ("to_string",):
            return self.text(self.value(self.eval(node.args[0])))
        if name == "string":                                          # string("-"), string(4, ' ')
            args = [self.value(self.eval(a)) for a in node.args]
            if len(args) == 2:
                return str(args[1]) * int(args[0])
            return self.text(args[0]) if args else ""
        if name in CTYPE and len(node.args) == 1:                     # isalnum(c), toupper(c), ...
            c = self.value(self.eval(node.args[0]))
            ch = chr(c) if isinstance(c, int) else str(c)[:1]
            out = CTYPE[name](ch)
            return Char(out) if isinstance(out, str) else out
        if name in self.structs:                                      # Student(…): a temporary object
            args = [self.eval_init(a) for a in node.args]
            return self.make_struct(name, [], ("tmp",), ctor_args=args)
        this = self.this[-1]
        if this is not None and isinstance(this.value, Struct) and \
                name in self.structs[this.value.type].methods:           # isEmpty() inside another method
            m = self.pick(self.structs[this.value.type].methods[name], len(node.args))
            if m is not None:
                return self.call_function(m, self.bind_args(m, node.args), node.line, this=this, evaluated=True)
        if name in ALGORITHMS and name not in self.funcs:
            return self.algorithm(name, node)
        funcs = self.funcs.get(name)
        if not funcs:
            raise CppError(f"unknown function {name}")
        fn = self.pick(funcs, len(node.args))
        args = self.bind_args(fn, node.args)
        self.emit("call", node.line, name=name, args=[snap(a.value if isinstance(a, Box) else a) for a in args],
                  params=[p[1] for p in fn.params], depth=self.depth)
        try:
            return self.call_function(fn, args, node.line, evaluated=True)
        finally:
            self.emit("leave", node.line, name=name, depth=self.depth)

    def algorithm(self, name: str, node: Call):
        """The <algorithm> / <numeric> calls data-structure code uses, over pointer ranges."""
        args = [self.value(self.eval(a)) for a in node.args]
        if len(args) < 2 or not isinstance(args[0], Ptr) or args[0].array is None:
            raise CppError(f"{name} needs an iterator range")
        arr, a = args[0].array, args[0].index
        b = args[1].index if isinstance(args[1], Ptr) and args[1].array is arr else len(arr.items)
        boxes = arr.items[a:b]
        values = [bx.value for bx in boxes]
        if name in ("sort", "stable_sort"):
            desc = len(args) > 2 and isinstance(args[2], Comparator) and args[2].kind == "greater"
            for bx, v in zip(boxes, sorted(values, reverse=desc)):
                if bx.value != v:
                    self.store(bx, v, node, node.line)
            return None
        if name == "reverse":
            for bx, v in zip(boxes, list(reversed(values))):
                if bx.value != v:
                    self.store(bx, v, node, node.line)
            return None
        if name == "fill":
            for bx in boxes:
                self.store(bx, args[2], node, node.line)
            return None
        if name == "iota":
            for k, bx in enumerate(boxes):
                self.store(bx, args[2] + k, node, node.line)
            return None
        if name == "is_sorted":
            desc = len(args) > 2 and isinstance(args[2], Comparator) and args[2].kind == "greater"
            return all((values[k] >= values[k + 1]) if desc else (values[k] <= values[k + 1])
                       for k in range(len(values) - 1))
        if name == "accumulate":
            total = args[2] if len(args) > 2 else 0
            for v in values:
                total = total + v
            return total
        if name == "count":
            return sum(1 for v in values if v == args[2])
        if name in ("find", "min_element", "max_element"):
            if name == "find":
                hits = [k for k, v in enumerate(values) if v == args[2]]
                k = hits[0] if hits else len(values)
            else:
                k = values.index(min(values) if name == "min_element" else max(values)) if values else 0
            return self.ptr_add(Ptr(arr.items[a] if a < len(arr.items) else None, arr, a), k) \
                if a + k <= len(arr.items) else Ptr(None, arr, a + k)
        raise CppError(f"{name} is not animated")

    def bind_args(self, fn: FuncDef, arg_nodes: list) -> list:
        out = []
        defaults = fn.defaults or next((g.defaults for g in self.funcs.get(fn.name, [])     # declared on
                                        if g.defaults and len(g.params) == len(fn.params)), {})  # the prototype
        arg_nodes = list(arg_nodes) + [defaults[k] for k in range(len(arg_nodes), len(fn.params)) if k in defaults]
        for k, a in enumerate(arg_nodes):
            spec = fn.params[k] if k < len(fn.params) else ("", "", False, False, False)
            ptype, _, is_array, by_ref, _ = spec
            if by_ref:
                box = self.box_of(a, quiet=True) if not isinstance(a, InitList) else None
                if box is None:                                      # a temporary bound to const&
                    raw = self.eval_init(a) if isinstance(a, InitList) else self.value(self.eval(a))
                    box = Box(self.convert(ptype, [], raw, ("tmp",)), ("tmp",), ptype)
                out.append(box)
            else:
                v = self.eval_init(a) if isinstance(a, InitList) else self.value(self.eval(a))
                out.append(v)
        return out

    def call_function(self, fn: FuncDef, args: list, line: int, this: Box | None = None, evaluated: bool = False):
        if fn.body is None:
            raise CppError(f"{fn.name} has no body")
        self.depth += 1
        if self.depth > MAX_DEPTH:
            raise CppError("recursion too deep to animate")
        frame: dict[str, Box] = {}
        for k, (ptype, pname, is_array, by_ref, is_ptr) in enumerate(fn.params):
            if k >= len(args):
                break
            a = args[k]
            if by_ref and isinstance(a, Box):
                frame[pname] = a                                       # the caller's own cell
            elif is_array or isinstance(self.value(a), Array) and not by_ref and is_array:
                frame[pname] = Box(self.value(a), (pname,), ptype)
            else:
                v = self.value(a)
                if isinstance(v, Array) and not is_array and not is_ptr:
                    v = self.copy_value(v, (pname,))                  # vectors are copied by value
                elif isinstance(v, Struct):
                    v = self.copy_value(v, (pname,))
                if isinstance(v, Array) and is_ptr:
                    v = Ptr(v.items[0] if v.items else None, v, 0)
                frame[pname] = Box(self.convert(ptype, [], v, (pname,), is_ptr) if not isinstance(v, Array) else v,
                                   (pname,), ptype + ("*" if is_ptr else ""))
        self.frames.append(frame)
        self.this.append(this)
        try:
            if fn.inits and this is not None and isinstance(this.value, Struct):
                for fname, init_args in fn.inits:
                    target = this.value.fields.get(fname)
                    if target is not None:
                        vals = [self.eval_init(x) if isinstance(x, InitList) else self.value(self.eval(x))
                                for x in init_args]
                        target.value = self.convert(target.type, [], vals[0] if len(vals) == 1 else vals,
                                                    target.path, target.type.endswith("*"))
            self.exec(fn.body)
            result = None
        except _Return as r:
            result = r.value
        finally:
            self.frames.pop()
            self.this.pop()
            self.depth -= 1
        return result

    def container_method(self, box: Box, name: str, node: Call):
        arr: Array = box.value
        args = [self.value(self.eval(a)) if not isinstance(a, InitList) else self.eval_init(a) for a in node.args]
        path = box.path
        if name in ("push_back", "push", "emplace_back", "emplace", "push_front"):
            k = len(arr.items) if name != "push_front" else 0
            item = Box(None, path + (k,), arr.elem)
            item.value = self.convert(arr.elem, [], args[0] if args else None, item.path)
            self.rebase(item.value, item.path)
            if name == "push_front":
                arr.items.insert(0, item)
                self.rebase(arr, path)
            else:
                arr.items.append(item)
            self.emit("push", node.line, path=list(path), value=snap(item.value), kind=arr.kind,
                      front=name == "push_front")
            return None
        if name in ("pop_back", "pop", "pop_front"):
            if not arr.items:
                raise CppError("pop from an empty container")
            front = name == "pop_front" or (name == "pop" and arr.kind == "queue")
            item = arr.items.pop(0 if front else -1)
            if front:
                self.rebase(arr, path)
            self.emit("pop", node.line, path=list(path), value=snap(item.value), kind=arr.kind, front=front)
            return None
        if name in ("size", "length"):
            return len(arr.items)
        if name == "empty":
            return not arr.items
        if name in ("back", "top"):
            if not arr.items:
                raise CppError("empty container")
            return arr.items[-1] if not (arr.kind == "stack" and name == "back") else arr.items[-1]
        if name == "front":
            if not arr.items:
                raise CppError("empty container")
            return arr.items[0]
        if name == "at":
            return arr.items[int(args[0])]
        if name in ("begin", "cbegin"):
            return Ptr(arr.items[0] if arr.items else None, arr, 0)
        if name in ("end", "cend"):
            return Ptr(None, arr, len(arr.items))
        if name in ("reserve", "shrink_to_fit"):
            return None
        if name in ("insert", "erase") and args and isinstance(args[0], Ptr) and args[0].array is arr:
            at = args[0].index
            if name == "insert":                     # insert(pos, value) / insert(pos, first, last)
                if len(args) == 3 and isinstance(args[1], Ptr) and args[1].array is not None:
                    src = args[1].array
                    new = [self.copy_value(b.value, ()) for b in src.items[args[1].index:args[2].index]]
                else:
                    new = [args[1]]
                arr.items[at:at] = [Box(self.convert(arr.elem, [], v, ()), (), arr.elem) for v in new]
            else:                                    # erase(pos) / erase(first, last)
                stop = args[1].index if len(args) > 1 and isinstance(args[1], Ptr) else at + 1
                del arr.items[at:stop]
            self.rebase(arr, path)
            self.emit("assign", node.line, path=list(path), value=snap(arr), src=node.src)
            return Ptr(arr.items[at] if at < len(arr.items) else None, arr, at)
        if name == "clear":
            arr.items.clear()
            self.emit("assign", node.line, path=list(path), value=snap(arr), src=node.src)
            return None
        if name in ("resize", "assign"):
            n = int(args[0])
            fill = args[1] if len(args) > 1 else 0
            arr.items = [Box(fill, path + (k,), arr.elem) for k in range(n)]
            self.emit("assign", node.line, path=list(path), value=snap(arr), src=node.src)
            return None
        raise CppError(f"{name} is not animated")

    def string_method(self, box: Box, name: str, node: Call):
        s: str = box.value
        args = [self.value(self.eval(a)) for a in node.args]
        if name in ("size", "length"):
            return len(s)
        if name == "empty":
            return not s
        if name == "substr":
            start = int(args[0])
            return s[start:start + int(args[1])] if len(args) > 1 else s[start:]
        if name == "find":
            k = s.find(str(args[0]))
            return k if k >= 0 else 2 ** 64 - 1
        if name in ("push_back", "append"):
            self.store(box, s + str(args[0]), node, node.line)
            return None
        if name == "c_str":
            return s
        if name == "clear":
            self.store(box, "", node, node.line)
            return None
        if name == "pop_back":
            self.store(box, s[:-1], node, node.line)
            return None
        if name in ("at", "back", "front"):
            k = int(args[0]) if name == "at" else (-1 if name == "back" else 0)
            return Char(s[k])
        raise CppError(f"string {name} is not animated")

    @staticmethod
    def printf(fmt: str, vals: list) -> str:
        out, k = [], 0

        def repl(m):
            nonlocal k
            spec, conv = m.group(1), m.group(2)
            if conv == "%":
                return "%"
            v = vals[k] if k < len(vals) else 0
            k += 1
            if conv in "di":
                return ("%" + spec + "d") % int(v)
            if conv in "fFeEgG":
                return ("%" + spec + conv) % float(v)
            if conv == "c":
                return ("%" + spec + "c") % (str(v)[:1] or " ")
            return ("%" + spec + "s") % (v if isinstance(v, str) else str(v))
        return re.sub(r"%([-+ #0]*\d*(?:\.\d+)?)(?:l{0,2}|h)?([diouxXfFeEgGcs%])", repl, fmt)


# ---------------------------------------------------------------- utilities

def names_used(code: str) -> set[str]:
    try:
        return {t.val for t in tokenize(code) if t.kind == "id"}
    except CppError:
        return set()


def format_path(path: list) -> str:
    return path_text(path)
