# Odoo setup tools

Everything needed to run Odoo 19 for the ERP practicals, on Windows, macOS or Linux. You do not need to install
anything first. Python, Odoo and PostgreSQL are downloaded into this folder, and nothing is installed on your computer.

Full instructions and troubleshooting are in the [setup guidelines](../ODOO-SETUP.md).

## Quick start

Open the menu, choose **1** to set up, then **2** to start Odoo:

| System | Open the menu |
| --- | --- |
| Windows | Double-click `tools\odoo.bat` |
| macOS | Double-click `tools/odoo.command` |
| Linux | Run `sh tools/odoo.sh` from the course folder |

```text
  1  Set up or repair everything
  2  Start Odoo and open the browser
  3  Show the web address and password
  4  Check that everything is working
  5  Show where everything is
  6  Delete the lab database and create it again
  0  Exit
```

You need an internet connection for the first setup, and about 2 GB of free disk space. Odoo opens at
<http://localhost:8070>. Sign in as `admin`; choose **3** to see the password.

## Commands

If you prefer typing, run these from the course folder. On Windows, start with `tools\odoo`. On macOS and Linux, start
with `sh tools/odoo.sh`.

| Command | What it does |
| --- | --- |
| `setup` | Downloads and sets up everything, or repairs what is missing. Safe to rerun |
| `start` | Starts the database and Odoo, and opens the browser. `Ctrl+C` stops them |
| `login` | Shows the web address and password |
| `check` | Reports on everything and changes nothing |
| `status` | Shows where everything is, and what is running |
| `stop` | Stops the database if it was left running |
| `shell` | Opens a Python shell inside Odoo |
| `run FILE` | Runs a script inside Odoo |
| `init` | Creates the lab database |
| `reset` | Deletes the lab database. It refuses names that do not end in `_labs` |

## What is in this folder

| Path | Contents |
| --- | --- |
| `odoo.bat`, `odoo.command`, `odoo.sh` | Launchers for Windows, macOS and Linux. They download Python on the first run |
| `setup_odoo.py` | The script that does the work |
| `constraints.txt` | The known-good version of each Python package |
| `runtime/` | Created by setup: Python 3.12, Odoo 19 and PostgreSQL 18. Not committed |
| `data/` | Created by setup: the database, passwords, logs and lab evidence. Not committed |

**To remove everything,** stop Odoo and delete `runtime` and `data`. Nothing is left elsewhere on the computer.

## Tested on

| System | Result |
| --- | --- |
| Windows 11 | Set up from nothing, with no Python, conda or PostgreSQL visible; all 105 lab checks pass |
| Ubuntu 24.04 | Clean machine, with no Python, compiler or PostgreSQL; all 105 lab checks pass |
| macOS | **Not yet tested.** Please report what you find |
