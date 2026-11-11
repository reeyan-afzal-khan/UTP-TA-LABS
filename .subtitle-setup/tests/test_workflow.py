import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from subtitles import render, timestamp
from transcribe import fingerprint
from common import atomic_text, discover
from run_lock import RunLock


class WorkflowTests(unittest.TestCase):
    def test_cross_platform_run_lease(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'active-run'
            with RunLock(path):
                self.assertTrue((path / 'owner.json').exists())
                with self.assertRaises(RuntimeError):
                    with RunLock(path): pass
            self.assertFalse(path.exists())

    def test_timestamp_carry(self):
        self.assertEqual(timestamp(59.9996), '00:01:00,000')
        self.assertEqual(timestamp(3600), '01:00:00,000')

    def test_no_words_lost_and_two_lines(self):
        tokens = 'A long lecture contains many words that must remain intact across all of the generated subtitle cues.'.split()
        words = [SimpleNamespace(word=w, start=i*0.4, end=i*0.4+0.3) for i, w in enumerate(tokens)]
        srt = render(words, width=20)
        actual = []
        for cue in srt.strip().split('\n\n'):
            lines = cue.splitlines()
            self.assertLessEqual(len(lines[2:]), 2)
            actual.extend(' '.join(lines[2:]).split())
        self.assertEqual(actual, tokens)

    def test_invalid_timings(self):
        with self.assertRaises(ValueError):
            render([SimpleNamespace(word='hello', start=float('nan'), end=1)])

    def test_resume_fingerprint_changes(self):
        with tempfile.TemporaryDirectory() as folder:
            p = Path(folder) / 'media.mp4'
            p.write_bytes(b'a')
            before = fingerprint(p, {'mode': 'verbatim'}, 'rev1')
            self.assertNotEqual(before, fingerprint(p, {'mode': 'intended'}, 'rev1'))
            self.assertNotEqual(before, fingerprint(p, {'mode': 'verbatim'}, 'rev2'))
            p.write_bytes(b'new media')
            self.assertNotEqual(before, fingerprint(p, {'mode': 'verbatim'}, 'rev1'))

    def test_atomic_utf8(self):
        with tempfile.TemporaryDirectory() as folder:
            p = Path(folder) / 'lecture.srt'
            atomic_text(p, 'café')
            self.assertEqual(p.read_text(encoding='utf-8'), 'café')
            self.assertFalse(p.with_name('lecture.srt.tmp').exists())

    def test_outside_media_rejected(self):
        with self.assertRaises(ValueError):
            discover('../.shared')


if __name__ == '__main__':
    unittest.main()
