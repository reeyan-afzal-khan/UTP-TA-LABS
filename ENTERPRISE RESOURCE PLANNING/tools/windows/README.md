# Odoo setup tools for Windows

Double-click `odoo.bat` in this folder. In the menu, choose **1** to set up, then **2** to start Odoo. Odoo opens at
<http://localhost:8070>. Sign in as `admin`; choose **3** to see the password.

The first setup needs an internet connection and about 2 GB of free disk space. Python, Odoo and PostgreSQL are downloaded
into this folder, and nothing is installed on your computer.

The [setup guidelines](../../ODOO-SETUP.md) have the full instructions and
[troubleshooting](../../ODOO-SETUP.md#troubleshooting). If you prefer typing, the [commands](../../ODOO-SETUP.md#commands)
run from the course folder, starting with `tools\windows\odoo`.

## What is in this folder

| Path | Contents |
| --- | --- |
| `odoo.bat` | The launcher. It downloads Python on the first run |
| `setup_odoo.py` | The script that does the work |
| `constraints.txt` | The known-good version of each Python package |
| `runtime\` | Created by setup: Python 3.12, Odoo 19, PostgreSQL 18 and Microsoft's C++ runtime. Not committed |
| `data\` | Created by setup: the database, passwords, logs and lab evidence. Not committed |

**To remove everything,** stop Odoo and delete `runtime` and `data`. Nothing is left elsewhere on the computer.

## If you set up Odoo before this folder existed

Your database is still in `tools\runtime` and `tools\data`. To keep it, stop Odoo and move those two folders into
`tools\windows`. Otherwise, choose **1** here and it sets up again from nothing.

This folder adds 8 characters to the path Windows has to fit. If setup now says `This folder is too deep for Windows`,
move the course folder closer to the drive, as the message says.

## Tested on

| System | Result |
| --- | --- |
| Windows 11 | Set up from nothing by double-clicking `odoo.bat`, with no Python, conda or PostgreSQL visible. All 105 lab checks pass, and signing in works. `Ctrl+C` and closing the window both stop the database cleanly. Every compiled file also loads with the PC's own C++ runtime out of reach, as on a PC that does not have it |
| Windows 10 | Not run |
