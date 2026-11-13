"""Publish a book and its chapter/lab PDFs from Typst's page metadata."""
from pathlib import Path
import argparse
from io import BytesIO
import json
import re
import shutil
import subprocess
import tempfile
import sys
from build import ROOT, SETUP, build, compiler, flags, courses, select

def publish(main):
    try:
        from pypdf import PdfReader, PdfWriter
    except ImportError:
        raise RuntimeError('Run .typst-setup/windows/step01-install.bat --publishing (Windows) or sh .typst-setup/unix/step01-install.sh --publishing (macOS/Linux)')
    source = build(main)
    config = json.loads((SETUP/'config'/'courses.json').read_text())[main.parent.name]
    expression = '(units: query(<unit>).map(u => u.value), headings: query(heading.where(level: 1)).map(h => (page: h.location().page(), number: if h.numbering != none { counter(heading).at(h.location()).first() } else { none })))'
    data = json.loads(subprocess.check_output([compiler(),'eval',expression,'--in',str(main),*flags()],text=True,encoding='utf-8'))
    reader = PdfReader(BytesIO(source.read_bytes()))
    units = data['units']
    for i, unit in enumerate(units):
        unit['end'] = units[i+1]['page']-1 if i+1<len(units) else len(reader.pages)
        unit['number'] = next((h['number'] for h in data['headings'] if h['page']==unit['page']),None)
        if unit['end'] < unit['page']: raise RuntimeError('Overlapping unit boundaries: '+str(unit))
    coverage = json.loads((SETUP/'config'/'lab-coverage.json').read_text())
    output_root = ROOT/'.all-pdfs'
    output_root.mkdir(exist_ok=True)
    destination = output_root/config['slug']
    if destination.resolve().parent != output_root.resolve(): raise RuntimeError('Unsafe publication directory')
    scratch_root = ROOT/'.build/publication'
    scratch_root.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(dir=scratch_root) as temporary:
        stage = Path(temporary)/'new'
        stage.mkdir()
        shutil.copy2(source,stage/(config['code']+'-Book.pdf'))
        def extract(unit, relative):
            target=stage/relative;target.parent.mkdir(parents=True,exist_ok=True)
            writer=PdfWriter()
            for page in reader.pages[unit['page']-1:unit['end']]: writer.add_page(page)
            writer.add_metadata({'/Title':unit['slug'],'/Creator':'UTP Typst publishing'})
            with target.open('wb') as stream:writer.write(stream)
        chapter_units=[u for u in units if u['kind'] in ('chapters','appendices')]
        pending=[];previous=[];manifest=[];labs=0
        for unit in units:
            if unit['kind']=='divider':continue
            if unit['kind'] in ('chapters','appendices'):
                pending.append(unit)
                continue
            if unit['kind']!='labs':continue
            labs+=1
            number=int(unit['slug'].split('-')[0])
            folder=f'Lab-{number:02d}'
            related=pending or previous
            labels=coverage.get(main.parent.name+'/'+unit['slug'])
            if labels:
                related=[u for u in chapter_units if any('<'+label.strip()+'>' in (main.parent/u['kind']/(u['slug']+'.typ')).read_text(encoding='utf-8') for label in labels)]
                if not related:raise RuntimeError('Lab coverage labels did not resolve: '+unit['slug'])
            counts={}
            for chapter in related:
                index=chapter['number'] or 0
                counts[index]=counts.get(index,0)+1
            seen={}
            for chapter in related:
                index=chapter['number'] or 0
                seen[index]=seen.get(index,0)+1
                suffix=chr(64+seen[index]) if counts[index]>1 else ''
                extract(chapter,f'{folder}/Chapter-{index:02d}{suffix}.pdf')
            extract(unit,f'{folder}/Lab-Activity.pdf')
            manifest.append({**unit,'folder':folder,'chapters':[c['slug'] for c in related]})
            previous=related;pending=[]
        for unit in pending:
            slug=unit['slug']
            name='Capstone-Project.pdf' if any(word in slug for word in ('capstone','final-project','final-revision')) else slug+'.pdf'
            extract(unit,name)
        # Courses without practicals still publish individual chapters.
        if not labs:
            for unit in chapter_units:extract(unit,unit['slug']+'.pdf')
        (stage/'manifest.json').write_text(json.dumps({'book':config['code']+'-Book.pdf','pages':len(reader.pages),'labs':manifest,'units':units},indent=2)+'\n',encoding='utf-8')
        # Swap only after every output is complete. Keep the old tree until the swap succeeds.
        backup=Path(temporary)/'previous'
        if destination.exists():destination.rename(backup)
        try:stage.rename(destination)
        except Exception:
            if backup.exists():backup.rename(destination)
            raise
    print(f'Published {config["code"]}: {len(reader.pages)} pages, {labs} labs -> {destination}')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('course',nargs='?')
    parser.add_argument('--all',action='store_true')
    args=parser.parse_args()
    if not args.all and not args.course:parser.error('Choose a course or --all')
    for course in courses() if args.all else [select(args.course)]:publish(course)

if __name__=='__main__':main()
