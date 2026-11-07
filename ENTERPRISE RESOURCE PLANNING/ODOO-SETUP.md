# Odoo 19 setup guidelines

These guidelines get Odoo 19 Community running for all eight labs, on Windows, macOS or Linux. **You do not need to
install anything first.** Python, Odoo and PostgreSQL are downloaded into your system's folder under `tools`, and stay
there. Your computer's settings, and any Python or database already on it, are not used or changed.

| System | Its folder |
| --- | --- |
| Windows | `tools\windows` |
| macOS, on Intel or Apple Silicon | `tools/mac` |
| Linux | `tools/linux` |

In these guidelines, `<system>` stands for `windows`, `mac` or `linux`.

## What you need

- An internet connection for the first setup. After that, Odoo works offline.
- About 2 GB of free disk space.
- Windows 10 version 1803 or newer, macOS 13 or newer (macOS 14 or newer on Apple Silicon), or Linux. Linux also needs
  `curl` or `wget`, which most systems have.
- On Windows, a course folder with only English letters in its path, and not too many folders deep. `C:\ERP` is a good
  place.

You do **not** need Python, Anaconda, PostgreSQL, Git, Node.js or a compiler.

| System | How far this has been tested |
| --- | --- |
| Windows 11 | Fully, from nothing to all 105 lab checks, by double-clicking `odoo.bat`, with no Python, conda or PostgreSQL visible. Every compiled file also loads with the PC's own C++ runtime out of reach, as on a PC that does not have it |
| Ubuntu 26.04, 24.04 and 22.04, Debian 13, Fedora 43, Arch Linux | Fully, from nothing to all 105 lab checks, each in WSL on an Intel or AMD PC |
| macOS 15 on Intel | Fully, from nothing to all 105 lab checks, and signing in through a browser |
| macOS on Apple Silicon | **Not run yet.** Its downloads were checked from an Intel Mac: the checksums match, the programs are correctly signed, and every package has a ready-made version. Please tell your instructor what happens |
| Windows 10, and Linux on ARM | **Not run yet.** Please tell your instructor what happens |

## Set it up

**1. Open the menu.**

| System | What to do | If it is blocked |
| --- | --- | --- |
| Windows | Double-click `odoo.bat` in the `tools\windows` folder | If *Windows protected your PC* appears, choose *More info*, then *Run anyway* |
| macOS | Double-click `odoo.command` in the `tools/mac` folder | See [If macOS blocks it](#if-macos-blocks-it) |
| Linux | Open a terminal in the course folder and run `sh tools/linux/odoo.sh` | Run it as your normal user, not as root |

The first time, it downloads Python into the folder. Then it shows this menu, which on Windows opens in a window of its
own:

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

**5. To stop Odoo,** press `Ctrl+C` in its window, or close the window. Next time, just open the menu and choose 2.

### If macOS blocks it

If you got the course as a download, macOS may refuse to open `odoo.command`, saying it cannot verify it. That is because
it is a script from outside the App Store, not because anything is wrong with it. Either of these gets past it:

- **Use Terminal, which needs no settings changed.** Open Terminal, type `cd ` with a space after it, drag the course
  folder into the window, and press Return. Then run `sh tools/mac/odoo.sh`.
- **Allow the file.** Try to open it once. Then open *System Settings*, choose *Privacy & Security*, scroll down, and
  choose *Open Anyway*.

If macOS asks whether Terminal may use your Desktop or Documents folder, choose *Allow*, because the course folder is
there.

Keep the course folder out of iCloud, OneDrive, Google Drive and Dropbox, because syncing can damage a running database.
This includes a Desktop or Documents folder that is synced to iCloud. Setup warns you if the folder is in one of them.

### If you use WSL on Windows

You do not need WSL, because `tools\windows` runs directly on Windows. If you would rather use it:

- **Keep the course folder in your Linux home folder,** and use `tools/linux`. A folder under `/mnt/c` will not do,
  because PostgreSQL refuses to keep its data on the Windows drive. The launcher stops and says so.
- **Open <http://localhost:8070> in a Windows browser yourself.** The browser may not open on its own.
- **Run only one of the two at a time,** because they use the same ports.

## How this relates to the install video

The [course video](https://www.youtube.com/watch?v=e9ffZ97NoD8) installs each piece by hand, and it is still the best
way to see what each one does. The `tools` folder does the same job, but keeps it all in one folder:

| In the video | With the `tools` folder |
| --- | --- |
| Install Git and clone Odoo from GitHub (4 GB) | Downloads a fixed Odoo 19 commit. No Git needed, and the course stays on Odoo 19 |
| Install Anaconda, add it to PATH, create an environment | A private Python 3.12 in `tools/<system>/runtime/python`. No PATH changes |
| `pip install setuptools wheel`, then `pip install -r requirements.txt` | The same steps, with fixed versions |
| Install PostgreSQL, add it to PATH, create a role in pgAdmin | A private PostgreSQL in `tools/<system>/runtime/postgres`, with the role created for you |
| Install Node.js and `rtlcss` | Left out, because only right-to-left languages need it |
| `python odoo-bin -r odoo -w odoo123 ...` | Choose 2 in the menu |
| Sign in with `admin` / `admin` | Sign in with a generated password |

The private Python is standard CPython, from the
[python-build-standalone](https://github.com/astral-sh/python-build-standalone) project, which packages it to run from
any folder. The private PostgreSQL comes from
[Zonky's embedded binaries](https://github.com/zonkyio/embedded-postgres-binaries). The launchers and script check
each of these downloads against a fixed checksum, and refuse to use one that does not match. On Windows, PostgreSQL also
needs Microsoft's C++ runtime, which not every PC has, so setup puts Microsoft's own files from the
[`msvc-runtime`](https://pypi.org/project/msvc-runtime/) package beside PostgreSQL. Python brings its own. Choosing **4**
in the menu confirms that both use these copies, not the computer's.

## Do the practicals

**To do them yourself,** follow each lab in the book in the browser. The labs share records, so work in the order of the
capstone's roadmap: Lab 1, Lab 7, Lab 3, Lab 4, Lab 5, then Labs 2, 6 and 8.

**To see them done, or to check your work,** this builds everything in the lab database and checks each result. Run it
on a new database, because it creates the records itself and will not run twice on the same one.

Windows:

```text
tools\windows\odoo run all_experiments\odoo_tasks\run_all_labs.py
```

macOS:

```text
sh tools/mac/odoo.sh run all_experiments/odoo_tasks/run_all_labs.py
```

Linux:

```text
sh tools/linux/odoo.sh run all_experiments/odoo_tasks/run_all_labs.py
```

It ends with a summary, and writes every check to `tools/<system>/data/results/evidence.json`. It also creates these
logins, which use the same password as `admin`:

| Login | Role | Department | Main apps |
| --- | --- | --- | --- |
| `sales.manager` | Sales Manager | Sales and Marketing (head) | CRM, Sales |
| `purchasing.officer` | Purchasing Officer | Supply Chain (head) | Purchase, Inventory |
| `production.planner` | Production Planner | Supply Chain | Manufacturing, Inventory |
| `accountant` | Accountant | Accounting and Finance (head) | Invoicing |
| `hr.officer` | HR Officer | Human Resources (head) | Employees |

Lab 6's calculation needs only Python. Use the line for your system, in the order Windows, macOS, Linux:

```text
tools\windows\runtime\python\python.exe all_experiments\sop_planner.py
tools/mac/runtime/python/bin/python3 all_experiments/sop_planner.py
tools/linux/runtime/python/bin/python3 all_experiments/sop_planner.py
```

**Still your own work:** the tutorial answers, research, slides, flowcharts, swimlanes and screenshots. The script
creates the records those are based on, not the submissions.

**To start the lab database again,** choose **6** in the menu. It permanently deletes the database and creates it again.

## Commands

The menu covers the everyday tasks. If you prefer typing, run these from the course folder. On Windows, start with
`tools\windows\odoo`. On macOS, start with `sh tools/mac/odoo.sh`. On Linux, start with `sh tools/linux/odoo.sh`.

| Command | What it does |
| --- | --- |
| `menu` | Shows the menu, in the same window |
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
| `tools/<system>/runtime/python` | Python 3.12 and Odoo's packages |
| `tools/<system>/runtime/odoo` | Odoo 19's code |
| `tools/<system>/runtime/postgres` | PostgreSQL 18 |
| `tools/<system>/data/pgdata` | The database, on port 54329 and reachable only from this computer |
| `tools/<system>/data/odoo-files` | Files uploaded to Odoo |
| `tools/<system>/data/odoo.conf` | Database settings |
| `tools/<system>/data/lab-login.txt`, `postgres-admin.txt` | Generated passwords. Never share or commit these |
| `tools/<system>/data/logs` | `odoo.log` and `postgres.log` |
| `tools/<system>/data/results` | The labs' evidence |

`runtime` and `data` are not committed to Git.

- **To back up your lab work,** stop Odoo and copy `tools/<system>/data`.
- **To start over but keep the downloads,** stop Odoo, delete `tools/<system>/data`, and choose 1.
- **To remove everything,** stop Odoo and delete `tools/<system>/runtime` and `tools/<system>/data`. Nothing is left
  elsewhere.
- **To move the course folder,** stop Odoo first. It keeps working in its new place.
- **To keep a setup made before the system folders existed,** stop Odoo and move `tools/runtime` and `tools/data` into
  your system's folder.

## What is left out

These are not needed for the labs:

- **Printing PDF reports.** Odoo needs `wkhtmltopdf` for this, so printing an invoice as a PDF gives an error. Take a
  screenshot for your evidence instead.
- **Right-to-left languages,** which need `rtlcss`.
- **Signing in through a company directory,** which needs `python-ldap`.

## Troubleshooting

| What you see | Cause | Fix |
| --- | --- | --- |
| The window closes at once on Windows | An error appeared and closed | Open a terminal in the course folder and run `tools\windows\odoo menu` to read it |
| `This folder is too deep for Windows` | The folder's path is too long for Windows | Move the course folder closer to the drive, such as `C:\ERP`, delete `tools\windows\runtime`, and try again |
| `This folder's path has letters that PostgreSQL cannot use` on Windows | The course folder's path has a letter that is not English, such as `é` or `中`. It may come from your Windows user name | Move the course folder to a plain path, such as `C:\ERP`, and try again |
| Windows says a `.dll` file was not found | The folder's path has a semicolon in it, and Windows cannot load programs from such a folder | Rename the folder |
| `Terminate batch job (Y/N)?` on Windows | You typed a command in a terminal, then pressed `Ctrl+C`. Odoo has already stopped | Type `Y`. The double-clicked menu does not ask this |
| Windows says a file is in use when you move or delete the folder | The database is still running | Run `tools\windows\odoo stop`, then try again |
| macOS says it cannot open or verify `odoo.command` | macOS checks files that came from a download | See [If macOS blocks it](#if-macos-blocks-it) |
| `you do not have appropriate access privileges` on a Mac | A download or cloud drive dropped the run permission | Open Terminal in the course folder and run `sh tools/mac/odoo.sh` |
| `Operation not permitted` on a Mac | Terminal may not use that folder | In *System Settings*, *Privacy & Security*, *Files & Folders*, allow Terminal. Or move the course folder into a new folder in your home folder |
| `This folder is synced to the cloud` | The course folder is in iCloud, OneDrive, Google Drive or Dropbox | Stop Odoo and move the course folder to one that is not synced. It keeps working there |
| `This Mac has macOS ...` | This macOS is older than the setup is made for | Update macOS. If you cannot, carry on and see what happens |
| `The private Python will not run on this Mac` | `tools/mac/runtime` came from a different type of Mac | Delete `tools/mac/runtime` and try again. Your work in `tools/mac/data` is kept |
| `Python could not be downloaded` | No connection, or a network blocks GitHub | Check your connection, or try another network |
| `This needs curl or wget` | Neither is installed on Linux | Install `curl`. On Ubuntu or Debian, run `sudo apt-get install -y curl` |
| `did not match its expected checksum` | The download was damaged or changed | Try again. If it repeats, tell your instructor |
| `Permission denied` for `odoo.sh` | Downloading can drop the run permission | Start it with `sh`, as shown |
| `Please run this as your normal user` | You are signed in as root on Linux, or used `sudo` | Run it as your normal user. A new WSL distro may have no other user: run `adduser yourname`, then `su - yourname` |
| `This course folder is on the Windows drive` | You ran the Linux setup in WSL, from a folder under `/mnt/c` | See [If you use WSL on Windows](#if-you-use-wsl-on-windows) |
| `gio: ... Operation not supported` on Linux | This computer has no browser set up to open web addresses, which is usual in WSL | This does no harm. Open <http://localhost:8070> yourself |
| `The database did not start` | Usually left over from a crash | Read the log it names, then run `stop` and try again |
| `port 54329 is answered by another PostgreSQL` | Another course copy is running | Stop that copy |
| `Port 8070 is already in use` | Odoo, or something else, is already on it | Open it if it is yours, or add `--port 8071` to `start` |
| `missing packages: ...` | The setup is incomplete | Choose 1 in the menu |
| A blank page on first visit | Odoo is still building its web files | Wait about a minute and reload |
| Printing a PDF gives an error | `wkhtmltopdf` is left out | Take a screenshot instead |

Odoo's log is `tools/<system>/data/logs/odoo.log`. To start completely fresh, stop Odoo, delete `tools/<system>/runtime`
and `tools/<system>/data`, and open the menu again.
