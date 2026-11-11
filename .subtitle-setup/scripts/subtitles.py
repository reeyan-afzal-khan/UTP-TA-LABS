"""Convert word timings into bounded, readable SRT cues without dropping words."""
import math
import textwrap


def timestamp(seconds):
    value = max(0, round(seconds * 1000))
    hours, value = divmod(value, 3600000)
    minutes, value = divmod(value, 60000)
    seconds, milliseconds = divmod(value, 1000)
    return f'{hours:02}:{minutes:02}:{seconds:02},{milliseconds:03}'


def render(words, width=42, max_lines=2, max_seconds=6.0):
    cues, group = [], []
    previous_end = 0.0
    def flush():
        nonlocal group, previous_end
        if not group:
            return
        start = max(previous_end, group[0][0])
        end = max(start + 0.001, group[-1][1])
        text = ' '.join(w[2] for w in group)
        lines = textwrap.wrap(text, width=width, break_long_words=False, break_on_hyphens=False)
        cues.append(f'{len(cues)+1}\n{timestamp(start)} --> {timestamp(end)}\n' + '\n'.join(lines))
        previous_end = end
        group = []
    for word in words:
        text = ' '.join(str(word.word).split())
        if not text:
            continue
        start, end = float(word.start), float(word.end)
        if not math.isfinite(start) or not math.isfinite(end) or end < start:
            raise ValueError('Model returned invalid word timestamps.')
        proposed = ' '.join([w[2] for w in group] + [text])
        lines = textwrap.wrap(proposed, width=width, break_long_words=False, break_on_hyphens=False)
        if group and (len(lines) > max_lines or end-group[0][0] > max_seconds or start-group[-1][1] > 0.8):
            flush()
        group.append((start, end, text))
        if text.endswith(('.', '?', '!')):
            flush()
    flush()
    return '\n\n'.join(cues) + ('\n' if cues else '')
