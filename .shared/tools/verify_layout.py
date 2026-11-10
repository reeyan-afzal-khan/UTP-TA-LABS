#!/usr/bin/env python3
"""Compare course PDFs: text, page geometry, and rasterized vector appearance."""
from pathlib import Path
from collections import Counter
import argparse
import subprocess
import tempfile
import unicodedata

def verify_pages(before: Path, after: Path, work: Path) -> int:
    from pypdf import PdfReader
    from PIL import Image, ImageChops, ImageStat, ImageFilter
    a, b = PdfReader(before), PdfReader(after)
    if len(a.pages) != len(b.pages):
        raise RuntimeError('Page counts differ.')
    for i, (left, right) in enumerate(zip(a.pages, b.pages), 1):
        if list(left.mediabox) != list(right.mediabox) or left.rotation != right.rotation:
            raise RuntimeError(f'Page {i} geometry differs.')
        def characters(page):
            return Counter(c for c in unicodedata.normalize('NFC', page.extract_text()) if not c.isspace())
        if characters(left) != characters(right):
            # Some math font encodings differ in pypdf after form extraction.
            def poppler_characters(pdf):
                text = subprocess.check_output(['pdftotext', '-f', str(i), '-l', str(i), str(pdf), '-']).decode('utf-8')
                return Counter(c for c in unicodedata.normalize('NFC', text) if not c.isspace())
            if poppler_characters(before) != poppler_characters(after):
                raise RuntimeError(f'Page {i} text differs.')
    # Compare every rendered page, not only extracted text: PDF text ordering can
    # change when a diagram becomes a form XObject even when pixels are identical.
    for generated in list(work.glob('before-*.png')) + list(work.glob('after-*.png')):
        generated.unlink()
    for label, pdf in [('before', before), ('after', after)]:
        subprocess.run(['pdftoppm', '-r', '96', '-png', str(pdf), str(work / label)],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    lefts, rights = sorted(work.glob('before-*.png')), sorted(work.glob('after-*.png'))
    if len(lefts) != len(a.pages) or len(rights) != len(a.pages):
        raise RuntimeError('Incomplete page render.')
    for n, (left, right) in enumerate(zip(lefts, rights), 1):
        with Image.open(left) as x, Image.open(right) as y:
            if x.size != y.size:
                raise RuntimeError(f'Page {n} raster dimensions differ.')
            diff = ImageChops.difference(x.convert('RGB'), y.convert('RGB'))
            red, green, blue = diff.split()
            maximum = ImageChops.lighter(ImageChops.lighter(red, green), blue)
            histogram = maximum.histogram()
            changed = sum(histogram[1:])
            pixels = x.width * x.height
            mean = ImageStat.Stat(maximum).mean[0]
            # Subpixel placement can change antialiasing on an entire text row.
            # Bound the raw difference and additionally require differences to
            # lie within the one-pixel edge envelope in BOTH directions.
            def outside_envelope(source, target):
                low = target.filter(ImageFilter.MinFilter(3))
                high = target.filter(ImageFilter.MaxFilter(3))
                return ImageChops.lighter(ImageChops.subtract(low, source),
                                          ImageChops.subtract(source, high))
            if changed / pixels > 0.0005 or mean > 0.03:
                edge = ImageChops.lighter(outside_envelope(x.convert('RGB'), y.convert('RGB')),
                                         outside_envelope(y.convert('RGB'), x.convert('RGB')))
                channels = edge.split()
                edge_max = ImageChops.lighter(ImageChops.lighter(channels[0], channels[1]), channels[2])
                edge_mean = ImageStat.Stat(edge_max).mean[0]
                edge_changed = sum(edge_max.histogram()[1:]) / pixels
                if changed / pixels > 0.01 or mean > 0.5 or edge_mean > 0.03 or edge_changed > 0.001:
                    # A thin rule can land exactly on a raster boundary. Require
                    # an independent, higher-resolution comparison before accepting it.
                    samples = []
                    for label, pdf in [('detail-before', before), ('detail-after', after)]:
                        prefix = work / label
                        subprocess.run(['pdftoppm', '-f', str(n), '-l', str(n), '-r', '144',
                                        '-singlefile', '-png', str(pdf), str(prefix)], check=True,
                                       stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
                        with Image.open(prefix.with_suffix('.png')) as sample:
                            samples.append(sample.convert('RGB'))
                    detail = ImageChops.difference(*samples)
                    r, g, b = detail.split()
                    detail_max = ImageChops.lighter(ImageChops.lighter(r, g), b)
                    detail_fraction = sum(detail_max.histogram()[1:]) / (samples[0].width * samples[0].height)
                    detail_mean = ImageStat.Stat(detail_max).mean[0]
                    if detail_fraction > 0.0005 or detail_mean > 0.03:
                        raise RuntimeError(f'Page {n} differs at both 96 and 144 dpi; inspect {work}.')
                    for label in ['detail-before.png', 'detail-after.png']:
                        (work / label).unlink()
        left.unlink()
        right.unlink()
    return len(a.pages)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('before', type=Path)
    parser.add_argument('after', type=Path)
    parser.add_argument('--work-dir', type=Path)
    args = parser.parse_args()
    work = args.work_dir or Path(tempfile.mkdtemp(prefix='utp-verify-'))
    work.mkdir(parents=True, exist_ok=True)
    print(f'Validation files: {work}', flush=True)
    pages = verify_pages(args.before.resolve(), args.after.resolve(), work.resolve())
    print(f'PASS: {pages} pages; text, page geometry and rendered appearance verified.')

if __name__ == '__main__':
    main()
