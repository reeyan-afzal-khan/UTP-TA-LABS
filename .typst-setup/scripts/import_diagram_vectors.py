"""Preserve archived vector geometry as native CeTZ path data (no rasterization)."""
from pathlib import Path
import json
import math
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
NUMBER = r'[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][-+]?\d+)?'
IDENTITY = (1, 0, 0, 1, 0, 0)


def multiply(a, b):
    aa, ab, ac, ad, ae, af = a
    ba, bb, bc, bd, be, bf = b
    return (aa*ba+ac*bb, ab*ba+ad*bb, aa*bc+ac*bd, ab*bc+ad*bd,
            aa*be+ac*bf+ae, ab*be+ad*bf+af)


def transform(value):
    result = IDENTITY
    for name, args in re.findall(r'(\w+)\(([^)]*)\)', value):
        n = list(map(float, re.findall(NUMBER, args)))
        if name == 'matrix': matrix = tuple(n)
        elif name == 'translate': matrix = (1, 0, 0, 1, n[0], n[1] if len(n)>1 else 0)
        elif name == 'scale': matrix = (n[0], 0, 0, n[-1], 0, 0)
        else: raise ValueError('Unsupported transform: '+name)
        result = multiply(result, matrix)
    return result


def commands(data, matrix, height):
    tokens = re.findall(r'[A-Za-z]|'+NUMBER, data)
    out, i, cmd, current, origin = [], 0, None, (0, 0), (0, 0)
    def point(x, y):
        a,b,c,d,e,f = matrix
        return [round(a*x+c*y+e, 4), round(height-(b*x+d*y+f), 4)]
    while i < len(tokens):
        if tokens[i].isalpha(): cmd=tokens[i]; i+=1
        upper=cmd.upper()
        if upper=='Z': out.append(['Z']); current=origin; cmd=None; continue
        count={'M':2,'L':2,'H':1,'V':1,'C':6,'Q':4}[upper]
        values=list(map(float,tokens[i:i+count])); i+=count
        relative=cmd.islower()
        if upper=='H': values=[values[0]+(current[0] if relative else 0),current[1]]; upper='L';relative=False
        if upper=='V': values=[current[0],values[0]+(current[1] if relative else 0)]; upper='L';relative=False
        pairs=[(values[j]+(current[0] if relative else 0),values[j+1]+(current[1] if relative else 0)) for j in range(0,len(values),2)]
        current=pairs[-1]
        out.append([upper,*[point(*p) for p in pairs]])
        if upper=='M': origin=current;cmd='l' if relative else 'L'
    return out


def convert(source):
    root=ET.parse(source).getroot()
    width,height=map(float,(root.get('width'),root.get('height')))
    ids={e.get('id'):e for e in root.iter() if e.get('id')}
    inherited=('fill','stroke','stroke-width','fill-rule','stroke-linecap','stroke-linejoin','stroke-dasharray','stroke-opacity','fill-opacity','opacity')
    def walk(element, matrix=IDENTITY, style=None):
        style=dict(style or {})
        style.update({k:element.get(k) for k in inherited if element.get(k) is not None})
        matrix=multiply(matrix,transform(element.get('transform','')))
        tag=element.tag.split('}')[-1]
        if tag=='defs': return []
        if tag in ('svg','g','clipPath'):
            result=[]
            for child in element: result.extend(walk(child,matrix,style))
            if element.get('clip-path'):
                clip_id=re.fullmatch(r'url\(#(.+)\)',element.get('clip-path')).group(1)
                return [{'clip':walk(ids[clip_id],matrix), 'items':result}]
            return result
        if tag=='use':
            target=ids[element.get('{http://www.w3.org/1999/xlink}href')[1:]]
            return walk(target,matrix,style)
        if tag!='path': raise ValueError('Unsupported SVG element: '+tag)
        d=commands(element.get('d',''),matrix,height)
        if not d:return []
        scale=math.sqrt(abs(matrix[0]*matrix[3]-matrix[1]*matrix[2]))
        fill=style.get('fill','#000000');stroke=style.get('stroke','none')
        # SVG fills implicitly close contours at a new move; CeTZ requires Z.
        # Open strokes instead need separate paths at each move command.
        groups=[]
        if fill!='none':
            normalized=[]
            for command in d:
                if command[0]=='M' and normalized and normalized[-1][0]!='Z': normalized.append(['Z'])
                normalized.append(command)
            if normalized[-1][0]!='Z': normalized.append(['Z'])
            groups=[normalized]
        else:
            for command in d:
                if command[0]=='M':groups.append([])
                groups[-1].append(command)
        return [{'d':group,'fill':fill,'stroke':stroke,'width':round(float(style.get('stroke-width',1))*scale,4),
                 'cap':style.get('stroke-linecap','butt'),'join':style.get('stroke-linejoin','miter'),
                 'rule':'even-odd' if style.get('fill-rule')=='evenodd' else 'non-zero',
                 'fill-opacity':float(style.get('fill-opacity',style.get('opacity',1))),
                 'stroke-opacity':float(style.get('stroke-opacity',style.get('opacity',1))),
                 'dash':[round(float(v)*scale,4) for v in re.findall(NUMBER,style.get('stroke-dasharray',''))]} for group in groups
                if len({tuple(point) for command in group for point in command[1:]}) > 1]
    def combine(items):
        result=[]
        for item in items:
            if 'items' in item: item['items']=combine(item['items'])
            if result and 'd' in item and 'd' in result[-1] and item['stroke']=='none' and len(result[-1]['d'])<400:
                previous=result[-1]
                if {k:v for k,v in item.items() if k!='d'}=={k:v for k,v in previous.items() if k!='d'}:
                    previous['d'].extend(item['d']);continue
            result.append(item)
        return result
    def native(items):
        for item in items:
            if 'items' in item:
                native(item['items']);native(item['clip']);continue
            paths=[];origin=None;segments=[]
            for command in item.pop('d'):
                kind=command[0]
                if kind=='M':
                    if segments:paths.append([origin,False,segments])
                    origin=[*command[1],0];segments=[]
                elif kind=='Z':
                    if segments:paths.append([origin,True,segments])
                    segments=[]
                else:segments.append([kind.lower(),*[[*p,0] for p in command[1:]]])
            if segments:paths.append([origin,False,segments])
            item['paths']=paths
        return items
    data={'width':width,'height':height,'items':native(combine(walk(root)))}
    target=source.with_suffix('.cetz.json')
    target.write_text(json.dumps(data,separators=(',',':'))+'\n',encoding='utf-8')


if __name__=='__main__':
    sources=sorted(ROOT.glob('*/figures/diagrams/*.svg'))
    for p in sources:
        if not p.parts[-4].startswith('.'):convert(p)
    print('Converted',len(sources),'vector diagrams to CeTZ data.')
