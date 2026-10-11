"""UTP lecture engine: turns the course LaTeX into narrated Manim lecture videos.

Pipeline (one lecture = one chapter or one lab file):

    LaTeX  --latex/-->  blocks  --script.py-->  lecture script (YAML, editable)
           --voice.py-->  audio per cue (TTS or your recordings), with word timings
           --figures.py-->  TikZ figures compiled with the book's preamble, as SVG
           --render/-->  Manim Community scene, paced by the audio
           --publish.py-->  .all_lectures/<course>/<chapters|labs>/<name>.mp4 + .srt
"""

ENGINE_VERSION = "1.0"
