# Odoo setup tools for macOS

For a Mac with an **Intel or Apple Silicon** chip. The launcher checks which one you have and downloads the right files.

Double-click `odoo.command` in this folder. In the menu, choose **1** to set up, then **2** to start Odoo. Odoo opens at
<http://localhost:8070>. Sign in as `admin`; choose **3** to see the password.

The first setup needs an internet connection and about 2 GB of free disk space. Python, Odoo and PostgreSQL are downloaded
into this folder, and nothing is installed on your computer.

**If macOS will not open `odoo.command`,** use Terminal instead, which needs no settings changed. Type `cd ` with a space
after it, drag the course folder into the window, and press Return. Then run:

```bash
sh tools/mac/odoo.sh
```

If macOS asks whether Terminal may use your Desktop or Documents folder, choose *Allow*.

The [setup guidelines](../../ODOO-SETUP.md) have the full instructions and
[troubleshooting](../../ODOO-SETUP.md#troubleshooting). If you prefer typing, the [commands](../../ODOO-SETUP.md#commands)
run from the course folder, starting with `sh tools/mac/odoo.sh`.

## Which Macs this works on

| Mac | macOS |
| --- | --- |
| Intel | 13 Ventura or newer |
| Apple Silicon (M1 and later) | 14 Sonoma or newer |

On an older macOS, setup warns you and carries on, but it may fail. PostgreSQL's files are built for macOS 13. On Apple
Silicon, the ready-made package for Odoo's version of `libsass` needs macOS 14.

Keep the course folder out of iCloud, OneDrive, Google Drive and Dropbox, because syncing can damage a running database.
Setup warns you if it is in one of them, including a Desktop or Documents folder synced to iCloud.

## What is in this folder

| Path | Contents |
| --- | --- |
| `odoo.command` | Double-click this to open the menu |
| `odoo.sh` | The launcher. It downloads Python on the first run |
| `setup_odoo.py` | The script that does the work |
| `constraints.txt` | The known-good version of each Python package on a Mac |
| `runtime/` | Created by setup: Python 3.12, Odoo 19 and PostgreSQL 18. Not committed |
| `data/` | Created by setup: the database, passwords, logs and lab evidence. Not committed |

`runtime` belongs to one type of Mac, so do not copy it between an Intel Mac and an Apple Silicon one. On the new Mac,
delete it and choose **1**, which downloads it again and leaves `data` alone.

**To remove everything,** stop Odoo and delete `runtime` and `data`. Nothing is left elsewhere on the computer.

## Tested on

| Mac | Result |
| --- | --- |
| Intel, macOS 15.7 | Set up from nothing, with Anaconda active and no compiler available; all 105 lab checks pass; signing in through a browser works; the menu, `Ctrl+C` and closing the window all behave |
| Apple Silicon | **Not run yet,** because this was prepared on an Intel Mac. Its Python, PostgreSQL and compiled packages were downloaded and inspected from there: checksums match, signatures are valid, and every package has a ready-made arm64 version. Please report what you find |
