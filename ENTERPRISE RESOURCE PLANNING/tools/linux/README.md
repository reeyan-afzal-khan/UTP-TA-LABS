# Odoo setup tools for Linux

Open a terminal in the course folder and run the launcher, as your normal user and not as root:

```bash
sh tools/linux/odoo.sh
```

In the menu, choose **1** to set up, then **2** to start Odoo. Odoo opens at <http://localhost:8070>. Sign in as `admin`;
choose **3** to see the password.

The first setup needs an internet connection, `curl` or `wget`, and about 2 GB of free disk space. Python, Odoo and
PostgreSQL are downloaded into this folder, and nothing is installed on your computer.

The [setup guidelines](../../ODOO-SETUP.md) have the full instructions and
[troubleshooting](../../ODOO-SETUP.md#troubleshooting). If you prefer typing, the [commands](../../ODOO-SETUP.md#commands)
run from the course folder, starting with `sh tools/linux/odoo.sh`.

## What is in this folder

| Path | Contents |
| --- | --- |
| `odoo.sh` | The launcher. It downloads Python on the first run |
| `setup_odoo.py` | The script that does the work |
| `constraints.txt` | The known-good version of each Python package |
| `runtime/` | Created by setup: Python 3.12, Odoo 19 and PostgreSQL 18. Not committed |
| `data/` | Created by setup: the database, passwords, logs and lab evidence. Not committed |

**To remove everything,** stop Odoo and delete `runtime` and `data`. Nothing is left elsewhere on the computer.

## If you use WSL on Windows

You do not need WSL, because `tools\windows` runs directly on Windows. If you would rather use it, keep the course folder
in your Linux home folder. The launcher refuses a folder under `/mnt/c`, because PostgreSQL refuses to keep its data on
the Windows drive. Open <http://localhost:8070> in a Windows browser yourself, because the browser may not open on its
own. Run only one of `tools\windows` and `tools/linux` at a time, because they use the same ports.

## If you set up Odoo before this folder existed

Your database is still in `tools/runtime` and `tools/data`. To keep it, stop Odoo and move those two folders into
`tools/linux`. Otherwise, choose **1** here and it sets up again from nothing.

## Tested on

| System | Result |
| --- | --- |
| Ubuntu 26.04 and 24.04, Debian 13, Fedora 43, Arch Linux | Set up from nothing, with no compiler or PostgreSQL, in WSL on an Intel or AMD PC. All 105 lab checks pass, and signing in works. `Ctrl+C` and closing the terminal stop Odoo and the database, and leave nothing running |
| Ubuntu 22.04 | The same, but closing the terminal was not tried |
| Linux on ARM | Not run |
