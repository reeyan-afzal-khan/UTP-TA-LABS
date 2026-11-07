# Odoo setup tools

Everything needed to run Odoo 19 for the ERP practicals. You do not need to install anything first. Each system has its
own folder. Python, Odoo and PostgreSQL are downloaded into that folder, and nothing is installed on your computer.

Full instructions and troubleshooting are in the [setup guidelines](../ODOO-SETUP.md).

## Quick start

Open the menu for your system, choose **1** to set up, then **2** to start Odoo:

| System | Folder | Open the menu |
| --- | --- | --- |
| Windows | [`windows`](windows/README.md) | Double-click `tools\windows\odoo.bat` |
| macOS, Intel or Apple Silicon | [`mac`](mac/README.md) | Double-click `tools/mac/odoo.command` |
| Linux | [`linux`](linux/README.md) | Run `sh tools/linux/odoo.sh` from the course folder |

Odoo opens at <http://localhost:8070>. Sign in as `admin`; choose **3** to see the password.

## What is in each folder

| Path | Contents |
| --- | --- |
| `odoo.bat`, `odoo.command`, `odoo.sh` | That system's launcher. It downloads Python on the first run |
| `setup_odoo.py` | The script that does the work |
| `constraints.txt` | The known-good version of each Python package |
| `README.md` | What is particular to that system, and how far it has been tested |
| `runtime`, `data` | Created by setup. Not committed |

Each folder is a complete copy and does not need the others, so a fix to `setup_odoo.py` has to be made in each copy that
needs it.

`.gitattributes` applies to all three folders, and keeps each launcher's line endings right.

## If you set up Odoo before these folders existed

Your setup is still in `tools/runtime` and `tools/data`. To keep your database, stop Odoo and move both into your system's
folder. Otherwise, delete them and set up again from that folder.

## Looking after these tools

[`MAINTAINER-NOTES.md`](MAINTAINER-NOTES.md) says how far each copy has been tested, how the copies differ, and what is left
to do.
