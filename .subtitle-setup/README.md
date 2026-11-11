# Course subtitles with CrisperWhisper 2.0 Large

**Recommended: [WSL2 CUDA CT2 setup](wsl/README.md).** It is installed and tested on this machine. The existing `windows/step05-transcribe.bat` and the Windows VS Code transcription task now use WSL. The instructions below describe the native Transformers fallback.

This workflow uses `nyralabs/CrisperWhisper2.0_large` locally on an NVIDIA GPU. Each video gets a UTF-8 subtitle with the same basename, in the same folder:

```text
.courses/SQL/Some course/lesson01.mp4
.courses/SQL/Some course/lesson01.srt
```

Videos and audio are never modified. The initial inventory contains 2,364 videos and one MP3. No cloud transcription service receives your recordings; the initial installation and model download need internet access.

## Native Windows fallback

Run these commands from the repository root. The scripts also work when invoked by absolute path from another folder. Activation of the virtual environment is unnecessary.

```bat
.subtitle-setup\windows\step01-install.bat
.subtitle-setup\windows\step02-check.bat
.subtitle-setup\windows\step03-download-model.bat
.subtitle-setup\windows\step04-inventory.bat
```

Test the first minute of one video before committing to a long batch:

```bat
.subtitle-setup\windows\step05-transcribe-native.bat --folder "SQL" --sample-seconds 60
```

Samples go to `runtime/samples/`, never beside the video, and never mark a full video complete. Watch the sample against the original video to assess the words and timing.

Start with a small batch, then a course, then the full library:

```bat
.subtitle-setup\windows\step05-transcribe-native.bat --folder "SQL" --limit 3
.subtitle-setup\windows\step05-transcribe-native.bat --folder "SQL"
.subtitle-setup\windows\step05-transcribe-native.bat
```

Run **the same command again to resume**. Check progress from a second terminal:

```bat
.subtitle-setup\windows\step06-status.bat
```

In VS Code, **Terminal → Run Task** also offers `Subtitles: inventory`, `Subtitles: transcribe selected course`, and `Subtitles: show progress`. The Windows transcription task now uses WSL CT2; inventory and progress still read the shared workspace state.

The matching `unix/step*.sh` scripts are available for NVIDIA Linux machines with Python 3.11–3.13. Use `sh .subtitle-setup/unix/step01-install.sh`, etc. This configuration uses CUDA; macOS and CPU-only machines are not targets. Linux installation needs validation on the target machine.

## Numbered steps

| Step | Purpose |
| --- | --- |
| 01 install | Create `.venv`, install CUDA PyTorch and transcription packages, check dependencies |
| 02 check | Test an actual GPU matrix operation, imports and bundled FFmpeg |
| 03 download-model | Download and record an exact model revision; repeat to verify/resume the same snapshot |
| 04 inventory | Write `runtime/inventory.csv` and count media and existing subtitles |
| 05 transcribe | Process a selected folder, single file, or all media |
| 06 status | Show completed, failed and interrupted jobs |

## Controls for long jobs

- `--folder "Machine Learning"` selects a subtree. A single media path relative to `.courses` also works.
- `--limit 10` processes at most ten pending files. Completed jobs do not consume this limit.
- `--dry-run` lists the selected pending files without loading the model.
- `--language en` overrides the default English language. Use the actual language code for other courses.
- `--mode verbatim` retains fillers and repetitions (default). `--mode intended` produces cleaner reading subtitles. Existing subtitles are preserved when changing modes; add `--overwrite` deliberately to regenerate them.
- `--overwrite` replaces existing subtitles, including manual edits. It is never enabled by default.
- **Ctrl+C** stops a run. Completed files remain safe. The interrupted video restarts from its beginning next time; checkpointing is per video, not within a video.

Only one batch can run at a time across Windows and WSL. A forcibly killed process can leave `runtime/active-run/`; verify both environments are idle before removing that lease directory. The model stays loaded between files. Logs print the current filename and a heartbeat every 30 seconds, then audio duration and processing time when the file finishes. These are elapsed times, not estimated completion percentages. Read the per-video timings from a pilot batch to estimate your library's runtime.

Media are processed in natural filename order (`lesson2` before `lesson10`). Course videos remain in their existing nested folders.

Use mains power and prevent sleep in Windows while running. Closing the terminal stops transcription. The scripts do not change your power settings or install a background service.

## Resume, failures and output safety

`runtime/progress.sqlite3` records each media path, size/mtime, model revision, inference settings, status and subtitle hash. Matching completed subtitles are skipped. Existing untracked or manually edited subtitles are also preserved with a warning. Missing subtitles, failed files and interrupted files are retried on the next run. Changed inputs/settings with an existing subtitle require explicit `--overwrite`.

SRTs are written through a temporary file and atomically replaced only after inference succeeds. Word timings are grouped into cues with a target of two lines, 42 characters per line, six seconds per cue, and breaks at sentences or pauses. An unusually long single word can exceed those targets. Empty or invalid results are reported as failures for review, rather than creating a misleading completed subtitle.

Most file errors are logged and the next video continues. CUDA out-of-memory stops the batch to avoid failing the whole queue. Close other GPU workloads and rerun. There is no silent CPU fallback or automatic downgrade to a smaller model. FFmpeg selects the first audio stream; multi-audio videos need review if the desired language is on another stream.

## Environment and storage

```text
.subtitle-setup/
  README.md
  config/       model/settings, dependency pins and validated environment lock
  scripts/      shared Python implementations
  windows/      numbered Windows launchers
  unix/         matching shell launchers
  tests/        SRT and resume-fingerprint checks
  .venv/        isolated Python packages (ignored by Git)
  runtime/      model cache, revision record, logs, inventory, progress, samples
```

The environment is isolated from the Typst setup and the base Python installation. Python 3.13, PyTorch 2.10.0 with CUDA 12.8, CrisperWhisper 2.1.0 and Transformers 4.57.6 are pinned. The model itself is **CrisperWhisper 2.0 Large**; the inference package has a different version number. The official PyTorch wheel supplies its CUDA runtime; a separate CUDA Toolkit is unnecessary. The NVIDIA driver must support CUDA 12.8. FFmpeg comes from `imageio-ffmpeg`, so no system PATH changes are needed.

Allow roughly 15–25 GB for the environment, downloads and cache, plus temporary audio and output. Only the current video's mono 16 kHz WAV is extracted; it is deleted after processing. A forced process kill can leave an `audio-*` temporary directory in `runtime/`; it is safe to remove that directory when no batch is running. Keep `model.json`, the Hugging Face cache and `progress.sqlite3` to preserve the downloaded model and resume history. Environments are not portable folders: rerun step 01 on another machine, then step 03 to record its local model path.

## Validation on this machine

Validated on 11 November 2026 with Python 3.13.9 and the RTX 4060 Laptop GPU (8 GB): CUDA tensor operation passed, FFmpeg passed, `pip check` passed, and six workflow unit tests passed. A 60-second SQL course sample completed in approximately 12.4 seconds after model loading, producing 19 SRT cues through 59.86 seconds. Cue numbering, timestamps, non-overlap, and two-line/42-character limits passed inspection. Observed GPU use was about 6.9 GB. This is a short functional test, not a library-wide speed estimate or accuracy benchmark.

The sample is under `runtime/samples/`; no full-library transcription was launched during setup. Unix launchers are provided but were not executed on a Linux machine.

## Upstream references

- [CrisperWhisper API and backend documentation](https://github.com/nyrahealth/CrisperWhisper/blob/main/DOCS.md)
- [CrisperWhisper 2.0 Large model](https://huggingface.co/nyralabs/CrisperWhisper2.0_large)
- [Official PyTorch installation](https://pytorch.org/get-started/locally/)

The CrisperWhisper CT2 fork currently distributes Linux x86-64 wheels. This Windows setup uses the documented Transformers backend, CUDA and float16 with one worker for the 8 GB RTX 4060. Standard model weights carry a non-commercial research license; commercial use requires a separate license. No claim is made that one model is best for every accent, language or course; review a pilot sample before the full run.

Run the workflow checks with `.subtitle-setup\.venv\Scripts\python.exe -m unittest discover -s .subtitle-setup/tests -v`.
