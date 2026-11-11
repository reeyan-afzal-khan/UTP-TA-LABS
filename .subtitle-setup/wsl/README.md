# WSL2 CUDA transcription (recommended)

The Windows `windows/step05-transcribe.bat` launcher now delegates to **Ubuntu WSL2 + CrisperWhisper's CTranslate2 fork**. The VS Code selected-course transcription task does the same. The old Windows Transformers runner remains available as `windows/step05-transcribe-native.bat`.

## Run now

Setup and conversion are already complete on this machine. From the repository root:

```bat
.subtitle-setup\wsl\step05-transcribe.bat --folder "SQL" --limit 3
.subtitle-setup\wsl\step05-transcribe.bat --folder "SQL"
```

Omit `--folder` for the whole library. Rerun the same command to resume. Existing subtitles are preserved. Use a separate terminal for progress and GPU activity:

```bat
.subtitle-setup\wsl\step06-status.bat
.subtitle-setup\wsl\step07-monitor-gpu.bat
```

The monitor reports NVIDIA compute utilization, VRAM and power once per second. Task Manager's **3D** graph is not a measurement of CUDA inference. Occupied VRAM alone does not indicate whether kernels are executing. A model retains VRAM while it waits on audio decoding, token handling or file operations. The monitor command is more useful for diagnosing this workload; Ctrl+C stops monitoring.

## Setup on another Windows machine

Prerequisites: working Ubuntu WSL2, an NVIDIA Windows driver with WSL CUDA support, internet access, and Windows Python 3.11–3.13. `wsl -l -v` must show Ubuntu at version 2. No Linux display driver, system CUDA Toolkit, sudo installs, or Windows PATH changes are required by these scripts.

First prepare the native Windows environment and pinned source weights using `windows/step01-install.bat` and `windows/step03-download-model.bat` if they are not already present. Then:

```bat
.subtitle-setup\wsl\step01-install.bat
.subtitle-setup\wsl\step02-check.bat
.subtitle-setup\wsl\step03-prepare-model.bat
.subtitle-setup\wsl\step04-inventory.bat
.subtitle-setup\wsl\step05-transcribe.bat --folder "SQL" --sample-seconds 60
```

Step 01 installs a private Python 3.12.16 environment using uv 0.13.7; the uv archive's official SHA-256 digest is checked. Linux packages are pinned in `config/requirements-wsl.lock.txt`.

Step 03 installs **upstream CTranslate2 4.6.0 in the Windows conversion environment only**, uses the existing PyTorch installation to convert the pinned model once to float16, then copies it into Linux storage. The inference engine is **ctranslate2-crisperwhisper 4.7.1.post4 in WSL only**. These are separate environments: never install upstream `ctranslate2` or `faster-whisper` into the WSL environment, because they overwrite the fork. This split also avoids downloading Linux PyTorch just for conversion; the CPU wheel endpoint failed during setup here.

Step 02 checks CT2's CUDA device and supported compute types, plus FFmpeg. A sample run validates actual model inference. No Linux PyTorch is needed for CT2 inference, so `torch.cuda.is_available()` is not the relevant check in WSL.

The `.sh` launchers run from inside WSL. Step 03's `.sh` imports an already converted Windows export; use the `.bat` version from Windows for the complete conversion-and-import operation.

## File locations

| Location | Contents |
| --- | --- |
| `~/.local/share/utp-subtitles/.venv/` inside Ubuntu | Linux Python and the CUDA CT2 fork |
| `~/.local/share/utp-subtitles/runtime/ct2/` | Converted model on WSL's Linux filesystem |
| `~/.local/share/utp-subtitles/runtime/audio-*/` | Temporary WAV for the current file, removed afterward |
| Repository `.subtitle-setup/runtime/` | Shared logs, progress database, samples and Windows conversion export |
| Existing `.courses/` folders | Original videos and generated adjacent `.srt` files |

The large model and environment are on Linux storage to avoid repeated model loads from `/mnt/c`. Media need not be duplicated. The Windows driver supplies GPU passthrough; pip supplies CT2's CUDA user-space libraries. Float16 keeps the large model's precision; no smaller model or draft model is silently substituted.

For a differently named distribution, set `UTP_SUBTITLE_DISTRO` in Windows before running the launchers. Inside WSL, `UTP_SUBTITLE_WSL_HOME` can override the Linux installation directory. Do not move an existing venv between machines: rerun installation and model preparation.

## Resume and locking

Windows and WSL share `runtime/progress.sqlite3` and an atomic `runtime/active-run/` directory lease. Only one batch can run across both environments. Ctrl+C releases the lease and preserves completed outputs. A forced process kill can leave the lease behind: verify no transcription process remains in either Windows or WSL, then remove only `runtime/active-run/` before restarting. Its `owner.json` records the platform, PID and start time.

When switching backends, existing subtitles remain protected even if their original fingerprint differs. Use `--overwrite` only when deliberately regenerating them. An interrupted video restarts from its beginning.

## Validation

On 11 November 2026, Ubuntu WSL2 detected the RTX 4060 Laptop GPU and supported float16 CUDA inference. The same 60-second SQL clip took approximately **4.2 seconds with WSL CT2**, versus **12.4 seconds with native Windows Transformers**, excluding model load time: about **3x faster** in this short functional test. Both used the same pinned CrisperWhisper 2.0 Large revision and word timestamps. This is not a full-library throughput or accuracy benchmark. No full-library run was launched during setup.

References: [CrisperWhisper backends](https://github.com/nyrahealth/CrisperWhisper/blob/main/DOCS.md), [Microsoft CUDA on WSL](https://learn.microsoft.com/en-us/windows/ai/directml/gpu-cuda-in-wsl).
