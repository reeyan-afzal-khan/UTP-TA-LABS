# Maintainer notes

Where the Odoo tools stood on 7 November 2026, and what is left to do. Students do not need this: their instructions are
in the [setup guidelines](../ODOO-SETUP.md).

| Copy | System | State |
| --- | --- | --- |
| `windows` | Windows 11 | Run from nothing by double-clicking, on these files. All 105 lab checks pass |
| `linux` | Ubuntu 26.04 and 24.04, Debian 13, Fedora 43, Arch Linux | Run from nothing in WSL. All 105 lab checks pass, and `Ctrl+C` and closing the terminal leave nothing running |
| `linux` | Ubuntu 22.04 | Run from nothing in WSL. All 105 lab checks pass. Closing the terminal was not tried |
| `mac` | macOS 15.7 on Intel | Run from nothing. All 105 lab checks pass |
| `mac` | Apple Silicon | **Not run.** Its downloads were inspected from the Intel Mac. See [Test Apple Silicon](#test-apple-silicon) |

**Not tried anywhere:** Windows 10, Linux outside WSL, and Linux on ARM.

**A Windows PC without Microsoft's C++ runtime** was not available, so this was proven with Windows' own loader instead.
Each compiled file in a new install was loaded in a fresh process twice: with System32 searched, to see what it uses,
then with System32 left out and only Windows' own DLLs loaded first, as such a PC has them. The control was a copy of
PostgreSQL's files without the tools folder's runtime: 11 of its DLLs quietly used the PC's runtime, and exactly those 11
could not load without it. The install passed: all 41 DLLs beside `postgres.exe`, all 82 libraries the server can load,
and all 148 of Python's `.pyd` and `.dll` files. Nine more PostgreSQL libraries need Perl, Python 3.13 or Tcl, which this
build leaves out, so they load on no PC, and nothing here uses them. `check` also confirms it on every PC, from what
Python and the running database have loaded.

A few things on the Mac were only simulated, because that Mac could not show them: having no developer tools, and a
Desktop synced to iCloud. The *Open Anyway* steps for a blocked `odoo.command` were not tried, though the Terminal route
works on files marked as downloaded.

## What each copy has

Each folder is a complete copy, so a fix has to be made in each copy that needs it.

| What | `windows` | `mac` | `linux` |
| --- | --- | --- | --- |
| `Ctrl+C` in the menu stops the database (`run` in `cmd_menu`, `stop_database`) | Yes | Yes | Yes |
| Closing the window stops the database | Yes: PostgreSQL has a hidden console, and `stop_database_if_window_closes` stops it | Yes: `window_closed` | Yes: `window_closed`. Without it, Odoo also carries on, because it takes `SIGHUP` as a request to restart |
| Barcodes and QR codes work (`rl-renderPM`) | Yes: Odoo's own list has it for Windows | Yes: added in `write_lab_requirements` | Yes: added in the same place. Without it they give HTTP 500 |
| Microsoft's C++ runtime beside PostgreSQL, all of it (`setup_vc_runtime`), and `check` looking at what Python and the database really loaded (`verify_vc_runtime`) | Yes | Not needed | Not needed |
| The menu has a window of its own (`odoo.bat`) | Yes. A batch file behind the menu would ask `Terminate batch job (Y/N)?` | Not needed | Not needed |
| Refuses to run as root, before any download (the launcher) | Not needed | **Not yet** | Yes |
| Removes the empty `runtime/downloads` (`cmd_setup`) | Yes | **Not yet** | Yes |
| Accepts a path in the wrong letter case (`inside_tools`) | Yes | Yes | Not needed: Linux paths are exact |
| Refuses the Windows drive under WSL (the launcher) | Not needed | Not needed | Yes |
| Refuses a path with non-English letters (`odoo.bat`, and `main`) | Yes. PostgreSQL's programs get paths in the old code page, so Chinese turns to `??`, and an accented letter breaks their UTF-8 database | Not tried. It should not need this, as Linux does not | Not needed: a folder named `tést 中文` passes all 105 lab checks |

The two **Not yet** items are small, and safe to copy from `tools/linux` next time you are on a Mac. They were left out
because the Mac copy cannot be run from Windows, and it works without them.

To see the code for any of these:

```bash
diff tools/linux/setup_odoo.py tools/mac/setup_odoo.py
```

## How Windows and Linux were tested

- **Only committed files count.** Each test started from `git archive` of the files, unpacked into a new folder, so that
  nothing left on this machine could hide a problem. For work not yet committed, `git stash create` gives a commit to
  archive and changes nothing.
- **On Windows,** the `PATH` was cut down to `System32`, and conda's and Python's variables removed. `Start-Process` on
  `odoo.bat` does what a double-click does, including the window it opens.
- **On Linux,** each distro was a bare image brought in with `wsl --import` under a throwaway name, and tested as a normal
  user. `wsl --unregister` removes it again. The downloads and the labs ran as they would for a student.
- **Stopping was tested in a real terminal.** Python's `pty` module typed `Ctrl+C`, and closed the terminal, on Linux. On
  Windows, a script attached to the window's console and pressed the keys, and the window was closed with `WM_CLOSE`, which is
  what clicking its X sends.
- **Never run a WSL test while Odoo is running on Windows.** WSL forwards its localhost ports to Windows, so a test can
  end up talking to the other one. Run them one at a time.

To prove a copy on its own database, without touching the lab database or its evidence, use a throwaway one. Windows is
shown here, and the others are the same with their own launcher:

```text
tools\windows\odoo init --database x_labs
tools\windows\odoo run all_experiments\odoo_tasks\run_all_labs.py --database x_labs --results tools\windows\data\check-results
tools\windows\odoo reset --database x_labs
```

The second command should report `105/105 checks passed`.

## What else is different on a Mac

These have no equivalent in the other copies:

- **It asks for the real chip.** `uname -m` says `x86_64` on Apple Silicon when a shell runs under Rosetta, so the launcher
  asks `sysctl` instead.
- **It uses macOS's own `curl`, `tar` and `shasum`,** even when Anaconda's or Homebrew's come first on the `PATH`.
- **It stops macOS offering to install developer tools.** `rjsmin` has no ready-made Mac package, so pip builds it, and it
  tries to compile an optional part. On a Mac without the tools it is told not to, and runs as plain Python.
- **It warns about an old macOS or a synced folder,** which would otherwise fail later and in confusing ways.

The Mac and Linux `constraints.txt` hold the same versions. They fix `gevent`, `greenlet`, `python-magic` and the `zope`
packages, and leave out `colorama`, `msvc-runtime`, `pypiwin32` and `pywin32`, which only Windows needs.

## Test Apple Silicon

On an Apple Silicon Mac with macOS 14 or newer, from the course folder:

```bash
sh tools/mac/odoo.sh setup
```

```bash
sh tools/mac/odoo.sh run all_experiments/odoo_tasks/run_all_labs.py
```

The second command should report `105/105 checks passed`. It fills the lab database, so choose 6 in the menu afterwards to
get a clean one. Then record the result in `ODOO-SETUP.md`, `tools/mac/README.md` and these notes.

What was checked from the Intel Mac: the arm64 Python and PostgreSQL match the checksums in the scripts and are correctly
signed, and every compiled package has an arm64 version for macOS 14 to 27. On macOS 13 or older, `libsass` has none, so
setup warns that it may fail.

## Keeping things working

- **Commit a new launcher from a Mac or Linux machine,** so that Git records its run permission. Git on Windows does not,
  which is why the original `odoo.command` could not be double-clicked. From Windows, set it by hand with
  `git add --chmod=+x` and the file's path.
- **Keep `/tools/runtime/` and `/tools/data/` in the course's `.gitignore`** until nobody has a setup from before the split.
  Without them, Git would offer to commit those folders, including their passwords.
- **To get an original file back,** they are in commit `4ff8fe7`, directly under `tools`.
