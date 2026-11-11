"""UTP lecture engine: turns the course Typst into narrated Manim lecture videos.

Pipeline (one lecture = one chapter or one lab file):

    Typst  --typst/-->  blocks  --script.py-->  lecture script (YAML, editable)
           --voice.py-->  audio per cue (TTS or your recordings), with word timings
           --figures.py-->  Typst equations and reusable SVG figures
           --render/-->  Manim Community scene, paced by the audio
           --publish.py-->  .all_lectures/<course>/<chapters|labs>/<name>.mp4 + .srt
"""

ENGINE_VERSION = "1.0"
