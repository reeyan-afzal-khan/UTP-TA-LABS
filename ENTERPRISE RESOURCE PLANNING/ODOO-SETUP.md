# Odoo 19 setup guidelines

These guidelines get Odoo 19 Community running for all eight labs, on Windows, macOS or Linux. **You do not need to
install anything first.** Python, Odoo and PostgreSQL are downloaded into the course's `tools` folder and stay there.
Your computer's settings, and any Python or database already on it, are not used or changed.

## What you need

- An internet connection for the first setup. After that, Odoo works offline.
- About 2 GB of free disk space.
- Windows 10 version 1803 or newer, macOS, or Linux. Linux also needs `curl` or `wget`, which most systems have.

You do **not** need Python, Anaconda, PostgreSQL, Git, Node.js or a compiler.

| System | How far this has been tested |
| --- | --- |
| Windows 11 | Fully, from nothing to all 105 lab checks |
| Ubuntu 24.04 | Fully, from a clean machine to all 105 lab checks |
| macOS | **Not yet tested.** Please tell your instructor what happens |

## Set it up

**1. Open the menu.**

| System | What to do | If it is blocked |
| --- | --- | --- |
| Windows | Double-click `odoo.bat` in the `tools` folder | If *Windows protected your PC* appears, choose *More info*, then *Run anyway* |
| macOS | Double-click `odoo.command` in the `tools` folder | Right-click it and choose *Open*. If that does not work, open Terminal in the course folder and run `sh tools/odoo.sh` |
| Linux | Open a terminal in the course folder and run `sh tools/odoo.sh` | Run it as your normal user, not as root |

The first time, it downloads Python into the `tools` folder and then shows this menu:

```text
  Odoo 19 for the ERP practicals
  Not set up yet: choose 1. It downloads everything into the tools folder.

  1  Set up or repair everything
  2  Start Odoo and open the browser
  3  Show the web address and password
  4  Check that everything is working
  5  Show where everything is
  6  Delete the lab database and create it again
  0  Exit
```

**2. Choose 1.** It runs six steps, which took about 5 minutes in testing. A slower connection will take longer.

| Step | What it does |
| --- | --- |
| 1 Python | Confirms Python 3.12 is private to the `tools` folder, and adds pip's tools |
| 2 Odoo 19 | Downloads Odoo's code |
| 3 Packages | Installs Odoo's own `requirements.txt`, at the versions in `constraints.txt` |
| 4 PostgreSQL | Downloads a private PostgreSQL 18, and creates its database folder and an `odoo` role with a generated password |
| 5 Verify | Checks that everything works together, and comes from the `tools` folder |
| 6 Lab database | Creates `west_end_bicycles_labs`, with Malaysia as the country and the eight course apps |

If it stops, read the message, fix the cause, and choose 1 again. It keeps what is already done.

**3. Choose 2 to start Odoo.** Your browser opens at <http://localhost:8070>. Keep the Odoo window open, because closing
it stops Odoo.

**The first page takes about a minute**, and may look blank, while Odoo builds its web files. Wait and reload. Later
loads are quick.

**4. Sign in** as `admin`. To see the password, choose **3** in the menu. It was generated for you, so it is not the
usual `admin`.

**5. To stop Odoo,** press `Ctrl+C` in its window. Next time, just open the menu and choose 2.

## How this relates to the install video

The [course video](https://www.youtube.com/watch?v=e9ffZ97NoD8) installs each piece by hand, and it is still the best
way to see what each one does. The `tools` folder does the same job, but keeps it all in one folder:

| In the video | With the `tools` folder |
| --- | --- |
| Install Git and clone Odoo from GitHub (4 GB) | Downloads a fixed Odoo 19 commit. No Git needed, and the course stays on Odoo 19 |
| Install Anaconda, add it to PATH, create an environment | A private Python 3.12 in `tools/runtime/python`. No PATH changes |
| `pip install setuptools wheel`, then `pip install -r requirements.txt` | The same steps, with fixed versions |
| Install PostgreSQL, add it to PATH, create a role in pgAdmin | A private PostgreSQL in `tools/runtime/postgres`, with the role created for you |
| Install Node.js and `rtlcss` | Left out, because only right-to-left languages need it |
| `python odoo-bin -r odoo -w odoo123 ...` | Choose 2 in the menu |
| Sign in with `admin` / `admin` | Sign in with a generated password |

The private Python is standard CPython, from the
[python-build-standalone](https://github.com/astral-sh/python-build-standalone) project, which packages it to run from
any folder. The private PostgreSQL comes from
[Zonky's embedded binaries](https://github.com/zonkyio/embedded-postgres-binaries). The launchers and script check
each of these downloads against a fixed checksum, and refuse to use one that does not match.

## Do the practicals

**To do them yourself,** follow each lab in the book in the browser. The labs share records, so work in the order of the
capstone's roadmap: Lab 1, Lab 7, Lab 3, Lab 4, Lab 5, then Labs 2, 6 and 8.

**To see them done, or to check your work,** this builds everything in the lab database and checks each result. Run it
on a new database, because it creates the records itself and will not run twice on the same one.

Windows:

```text
tools\odoo run all_experiments\odoo_tasks\run_all_labs.py
```

macOS and Linux:

```text
sh tools/odoo.sh run all_experiments/odoo_tasks/run_all_labs.py
```

It ends with a summary, and writes every check to `tools/data/results/evidence.json`. It also creates these logins, which
use the same password as `admin`:

| Login | Role | Department | Main apps |
| --- | --- | --- | --- |
| `sales.manager` | Sales Manager | Sales and Marketing (head) | CRM, Sales |
| `purchasing.officer` | Purchasing Officer | Supply Chain (head) | Purchase, Inventory |
| `production.planner` | Production Planner | Supply Chain | Manufacturing, Inventory |
| `accountant` | Accountant | Accounting and Finance (head) | Invoicing |
| `hr.officer` | HR Officer | Human Resources (head) | Employees |

Lab 6's calculation needs only Python. On Windows, use the first line. On macOS and Linux, use the second:

```text
tools\runtime\python\python.exe all_experiments\sop_planner.py
tools/runtime/python/bin/python3 all_experiments/sop_planner.py
```

**Still your own work:** the tutorial answers, research, slides, flowcharts, swimlanes and screenshots. The script
creates the records those are based on, not the submissions.

**To start the lab database again,** choose **6** in the menu. It permanently deletes the database and creates it again.

## Commands

The menu covers the everyday tasks. If you prefer typing, run these from the course folder. On Windows, start with
`tools\odoo`. On macOS and Linux, start with `sh tools/odoo.sh`.

| Command | What it does |
| --- | --- |
| `setup` | Downloads and sets up everything, or repairs what is missing. Safe to rerun |
| `start` | Starts the database and Odoo, and opens the browser |
| `login` | Shows the web address and password |
| `check` | Reports on everything and changes nothing |
| `status` | Shows where everything is, and what is running |
| `stop` | Stops the database if it was left running |
| `shell` | Opens a Python shell inside Odoo |
| `run FILE` | Runs a script inside Odoo |
| `init` | Creates the lab database |
| `reset` | Deletes the lab database. It refuses names that do not end in `_labs` |

Add `--port 8071` to `start` to use another web port.

## Where everything is

| Path | Contents |
| --- | --- |
| `tools/runtime/python` | Python 3.12 and Odoo's packages |
| `tools/runtime/odoo` | Odoo 19's code |
| `tools/runtime/postgres` | PostgreSQL 18 |
| `tools/data/pgdata` | The database, on port 54329 and reachable only from this computer |
| `tools/data/odoo-files` | Files uploaded to Odoo |
| `tools/data/odoo.conf` | Database settings |
| `tools/data/lab-login.txt`, `postgres-admin.txt` | Generated passwords. Never share or commit these |
| `tools/data/logs` | `odoo.log` and `postgres.log` |
| `tools/data/results` | The labs' evidence |

`runtime` and `data` are not committed to Git.

- **To back up your lab work,** stop Odoo and copy `tools/data`.
- **To start over but keep the downloads,** stop Odoo, delete `tools/data`, and choose 1.
- **To remove everything,** stop Odoo and delete `tools/runtime` and `tools/data`. Nothing is left elsewhere.
- **To move the course folder,** stop Odoo first. It keeps working in its new place.

## What is left out

These are not needed for the labs:

- **Printing PDF reports.** Odoo needs `wkhtmltopdf` for this, so printing an invoice as a PDF gives an error. Take a
  screenshot for your evidence instead.
- **Right-to-left languages,** which need `rtlcss`.
- **Signing in through a company directory,** which needs `python-ldap`.

## Troubleshooting

| What you see | Cause | Fix |
| --- | --- | --- |
| The window closes at once on Windows | An error appeared and closed | Open a terminal in the course folder and run `tools\odoo` to read it |
| `This folder is too deep for Windows` | The folder's path is too long for Windows | Move the course folder closer to the drive, such as `C:\ERP`, delete `tools\runtime`, and try again |
| `Python could not be downloaded` | No connection, or a network blocks GitHub | Check your connection, or try another network |
| `This needs curl or wget` | Neither is installed on Linux | Run `sudo apt-get install -y curl` |
| `did not match its expected checksum` | The download was damaged or changed | Try again. If it repeats, tell your instructor |
| `Permission denied` for `odoo.sh` | Downloading can drop the run permission | Start it with `sh`, as shown |
| `PostgreSQL refuses to run as root` | You are signed in as root on Linux | Run it as your normal user |
| `The database did not start` | Usually left over from a crash | Read the log it names, then run `stop` and try again |
| `port 54329 is answered by another PostgreSQL` | Another course copy is running | Stop that copy |
| `Port 8070 is already in use` | Odoo, or something else, is already on it | Open it if it is yours, or add `--port 8071` to `start` |
| `missing packages: ...` | The setup is incomplete | Choose 1 in the menu |
| A blank page on first visit | Odoo is still building its web files | Wait about a minute and reload |
| Printing a PDF gives an error | `wkhtmltopdf` is left out | Take a screenshot instead |

Odoo's log is `tools/data/logs/odoo.log`. To start completely fresh, stop Odoo, delete `tools/runtime` and `tools/data`,
and open the menu again.
