"""Regression checks for SVG contour and transformation preservation."""
import json
from pathlib import Path
import tempfile
import unittest

from import_diagram_vectors import convert, commands, transform


class DiagramVectorsTest(unittest.TestCase):
    def converted(self, body):
        with tempfile.TemporaryDirectory() as folder:
            source = Path(folder) / "drawing.svg"
            source.write_text(f'<svg width="20" height="20">{body}</svg>')
            convert(source)
            return json.loads(source.with_suffix('.cetz.json').read_text())['items']

    def test_fill_closes_each_glyph_contour(self):
        items = self.converted('<path d="M0 0 L5 0 L5 5 M1 1 L2 1 L2 2"/>')
        self.assertEqual(len(items[0]['paths']), 2)
        self.assertTrue(all(path[1] for path in items[0]['paths']))

    def test_disconnected_strokes_are_not_joined(self):
        items = self.converted('<path fill="none" stroke="#000000" d="M0 0 L5 5 M10 10 L15 15"/>')
        self.assertEqual(len(items), 2)
        self.assertTrue(all(not item['paths'][0][1] for item in items))

    def test_degenerate_paths_are_omitted(self):
        self.assertEqual(self.converted('<path d="M1 1 L1 1 Z"/>'), [])

    def test_transforms_and_axis_commands(self):
        result = commands('M1 2 h3 v4', transform('translate(2,3) scale(2)'), 20)
        self.assertEqual(result, [['M', [4,13]], ['L', [10,13]], ['L', [10,5]]])


if __name__ == '__main__':
    unittest.main()
