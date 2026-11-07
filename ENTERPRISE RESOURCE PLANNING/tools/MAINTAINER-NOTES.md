# Maintainer notes

Where the Odoo tools stood on 7 November 2026, and what is left to do. Students do not need this: their instructions are
in the [setup guidelines](../ODOO-SETUP.md).

On that date the tools were split into `windows`, `mac` and `linux` folders, working on an Intel Mac. So the Mac copy is
the only one that has been run since the split.

| Copy | State |
| --- | --- |
| `mac`, on Intel | Run from nothing on macOS 15.7. All 105 lab checks pass |
| `mac`, on Apple Silicon | **Not run.** Its downloads were inspected from the Intel Mac. See [Test Apple Silicon](#test-apple-silicon) |
| `windows` | **Not run since the split.** It is the version that passed all 105 checks on Windows 11, with only its paths changed. See [When you first pull this on Windows](#when-you-first-pull-this-on-windows) |
| `linux` | **Not run since the split.** It is the version that passed all 105 checks on Ubuntu 24.04, with only its paths and one error message changed |

A few things on the Mac were only simulated, because that Mac could not show them: having no developer tools, and a
Desktop synced to iCloud. The *Open Anyway* steps for a blocked `odoo.command` were not tried, though the Terminal route
works on files marked as downloaded.

## When you first pull this on Windows

Stop Odoo before pulling. Then, from the course folder:

1. **Use the new launcher.** `tools\odoo.bat` has gone, and is now `tools\windows\odoo.bat`.

2. **Keep your existing database, if you want it.** The pull leaves `tools\runtime` and `tools\data` where they are,
   because Git ignores them. To carry on with them, move them:

   ```text
   move tools\runtime tools\windows\runtime
   move tools\data tools\windows\data
   ```

   To start fresh instead, delete both, and choose 1 in the menu.

3. **Check that it still works:**

   ```text
   tools\windows\odoo check
   ```

   It should end with `Everything is working`. If it says `This folder is too deep for Windows`, the new folder has pushed
   the path past the script's limit of 100 characters. It adds 8. `C:\Users\reeyanafzal\Desktop\...` comes to 96, and a
   OneDrive Desktop to 105. Move the course folder closer to the drive.

4. **Run all the labs on a throwaway database,** to prove this copy. The evidence goes to its own folder, so that your
   own is not overwritten:

   ```text
   tools\windows\odoo init --database windows_check_labs
   tools\windows\odoo run all_experiments\odoo_tasks\run_all_labs.py --database windows_check_labs --results tools\windows\data\check-results
   tools\windows\odoo reset --database windows_check_labs
   ```

   The second command should report `105/105 checks passed`.

5. **Record the result** in `ODOO-SETUP.md`, `tools/windows/README.md` and these notes.

## Fixes that only the Mac copy has

Testing on the Mac found these. **None is needed for the labs.** The Windows and Linux copies passed all 105 checks without
them, so leave those copies alone unless one of these gets in your way.

| Fix in `tools/mac/setup_odoo.py` | For Windows | For Linux |
| --- | --- | --- |
| Stop the database after `Ctrl+C` in the menu (`run` in `cmd_menu`, and `stop_database`) | Worth having. Probably the same problem, but not confirmed there | Worth having. The code is the same |
| Stop the database when the window closes (`window_closed`, and `main`) | Would need different code, because Windows has no `SIGHUP`. Not confirmed there | Worth having. The code is the same |
| Install `rl-renderPM`, which draws barcodes (`write_lab_requirements`) | Not needed. Odoo already lists it for Windows | Only if someone needs barcodes in a report. Not confirmed there |
| Accept a path in the wrong letter case (`inside_tools`) | Not needed. That copy already ignores case | Not needed. Linux paths are exact |

**What the database problem costs.** After `Ctrl+C` in the menu, or after closing the window, the database can keep running
in the background. This does the labs no harm: the next start uses it, and the `stop` command or a restart ends it. It only
gets in the way if you delete or move the course folder straight afterwards, so run `stop` first.

To see the code for any of these:

```bash
diff tools/linux/setup_odoo.py tools/mac/setup_odoo.py
```

## What else is different on a Mac

These have no equivalent in the other copies:

- **It asks for the real chip.** `uname -m` says `x86_64` on Apple Silicon when a shell runs under Rosetta, so the launcher
  asks `sysctl` instead.
- **It uses macOS's own `curl`, `tar` and `shasum`,** even when Anaconda's or Homebrew's come first on the `PATH`.
- **It stops macOS offering to install developer tools.** `rjsmin` has no ready-made Mac package, so pip builds it, and it
  tries to compile an optional part. On a Mac without the tools it is told not to, and runs as plain Python.
- **`constraints.txt` comes from a working Mac install,** so it also fixes `gevent`, `greenlet`, `python-magic` and the
  `zope` packages, and leaves out the ones only Windows needs.
- **It warns about an old macOS or a synced folder,** which would otherwise fail later and in confusing ways.

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
