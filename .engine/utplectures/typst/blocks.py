"""Semantic content blocks evaluated by the official compiler."""
from dataclasses import dataclass, field
from .reader import evaluate, inline, descendants, math_source

@dataclass
class Block:
    pass


@dataclass
class Heading(Block):
    level: int
    title: str
    starred: bool = False
    label: str | None = None


@dataclass
class LabBanner(Block):
    number: str
    title: str
    label: str | None = None


@dataclass
class Guide(Block):
    before: str
    outcomes: str


@dataclass
class Para(Block):
    markup: str


@dataclass
class ListItem:
    markup: str
    label: str | None = None
    children: list[Block] = field(default_factory=list)


@dataclass
class ListBlock(Block):
    kind: str
    items: list[ListItem]


@dataclass
class Callout(Block):
    env: str
    args: list[str | None]
    blocks: list[Block]


@dataclass
class CodeBlock(Block):
    code: str
    language: str | None = None
    style: str | None = None
    caption: str | None = None


@dataclass
class Column:
    width: float | None = None
    align: str = "l"
    bold: bool = False
    color: str | None = None


@dataclass
class TableBlock(Block):
    columns: list[Column]
    header: list[list[str]]
    rows: list[list[str]]


@dataclass
class FigureBlock(Block):
    body: str
    caption: str | None = None
    short: str | None = None
    label: str | None = None
    title: str | None = None
    image: str | None = None


@dataclass
class MathBlock(Block):
    markup: str


@dataclass
class InputRef(Block):
    path: str


class BlockParser:
    def __init__(self, styles):
        self.styles = styles

    def parse_file(self, text):
        return self.parse(evaluate(text))

    def parse(self, node):
        blocks, paragraph = [], []
        def flush():
            value = ''.join(paragraph).strip()
            if value: blocks.append(Para(value))
            paragraph.clear()
        def visit(n):
            if not isinstance(n, dict): return
            func = n.get('func')
            if func == 'sequence':
                for child in n.get('children', []): visit(child)
            elif func == 'parbreak': flush()
            elif func == 'heading':
                flush(); blocks.append(Heading(n.get('depth', n.get('level', 1))-1, inline(n.get('body', {})), n.get('numbering', 'auto') is None, n.get('label', '').strip('<>') or None))
            elif func == 'metadata':
                value = n.get('value', {})
                if not isinstance(value, dict): return
                flush()
                if value.get('utp') == 'callout':
                    kind = value['kind']
                    color = '#B34843' if kind in ('pitfall','debugtask') else '#138A80' if kind in ('keyidea','tryit','yourturn','labanswer') else '#2D7D46' if kind in ('verification','labcheckpoint','chapterrecap') else '#246B9E'
                    self.styles.register(kind, color)
                    blocks.append(Callout(kind, [inline(value['title'])], self.parse(value['body'])))
                elif value.get('utp') == 'lab': blocks.append(LabBanner(value['number'], inline(value['title'])))
                elif value.get('utp') == 'flow': blocks.append(ListBlock('enumerate', [ListItem(inline(v)) for v in value['items']]))
            elif func == 'raw' and n.get('block'):
                flush(); blocks.append(CodeBlock(n.get('text', ''), n.get('lang')))
            elif func == 'figure':
                flush()
                table = next((v for v in descendants(n.get('body')) if v.get('func') == 'table'), None)
                if table is not None: visit(table)
                else:
                    image = next((v for v in descendants(n.get('body')) if v.get('func') == 'image'), None)
                    if image:
                        blocks.append(FigureBlock('', caption=inline(n.get('caption', {})), label=n.get('label', '').strip('<>') or None, image=image.get('source')))
                    else: visit(n.get('body', {}))
            elif func == 'image':
                flush(); blocks.append(FigureBlock('', image=n.get('source')))
            elif func == 'table':
                flush(); count = len(n.get('columns', ['auto'])); headers=[]; cells=[]
                for child in n.get('children', []):
                    if child.get('func') == 'header':
                        headers.append([inline(c.get('body', {})) for c in child.get('children', []) if c.get('func') == 'cell'])
                    elif child.get('func') == 'cell':
                        cells.append(inline(child.get('body', {})))
                        cells.extend([''] * (child.get('colspan', 1)-1))
                blocks.append(TableBlock([Column() for _ in range(count)], headers, [cells[i:i+count] for i in range(0,len(cells),count)]))
            elif func in ('list', 'enum', 'terms'):
                flush(); items=[]
                for item in n.get('children', []):
                    items.append(ListItem(inline(item.get('body', item.get('description', {}))), inline(item.get('term', {})) or None))
                blocks.append(ListBlock({'list':'itemize','enum':'enumerate','terms':'description'}[func],items))
            elif func == 'item':
                flush()
                kind = 'description' if 'term' in n else 'enumerate' if 'number' in n else 'itemize'
                item = ListItem(inline(n.get('body', n.get('description', {}))), inline(n.get('term', {})) or None)
                if blocks and isinstance(blocks[-1], ListBlock) and blocks[-1].kind == kind: blocks[-1].items.append(item)
                else: blocks.append(ListBlock(kind,[item]))
            elif func == 'equation' and n.get('block'):
                flush(); blocks.append(MathBlock(math_source(n)))
            elif func in ('block','align','styled','box'):
                visit(n.get('body', n.get('child', {})))
            elif func in ('pagebreak','v','h','line','counter-update','state-update','context'): pass
            else: paragraph.append(inline(n))
        visit(node); flush()
        return blocks


