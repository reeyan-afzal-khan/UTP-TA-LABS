#!/usr/bin/env python3
"""Set up and run Odoo 19 for the ERP practicals, entirely inside the tools folder.

Run it through its launcher: double-click tools\\windows\\odoo.bat, or run tools\\windows\\odoo
from the course folder. With no command, it shows a menu.

    setup      download and set up everything, or repair what is missing
    start      start the database and Odoo, and open the browser
    stop       stop the database if it was left running
    login      show the web address and sign-in details
    check      report on everything; change nothing
    status     show where everything is, and what is running
    shell      open a Python shell inside Odoo
    run FILE   run a script inside Odoo
    init       create the lab database
    reset      delete the lab database (names ending _labs only)

Nothing is installed on the computer. Python, Odoo and PostgreSQL are downloaded into
tools\\windows\\runtime, and the database, passwords and logs live in tools\\windows\\data. To remove it all,
stop Odoo and delete those two folders. See ../../ODOO-SETUP.md.
"""
import argparse
import configparser
import contextlib
import hashlib
import importlib
import importlib.metadata as metadata
import io
import json
import os
import platform
import re
import secrets
import shutil
import site
import socket
import subprocess
import sys
import tarfile
import threading
import time
import urllib.request
import webbrowser
import zipfile
from pathlib import Path

PYTHON = (3, 12)
DATABASE = "west_end_bicycles_labs"
PORT = 8070
DB_PORT = 54329  # not PostgreSQL's usual 5432, so it cannot clash with one on this computer
DB_USER = "odoo"
APPS = "contacts,crm,hr,stock,account,mrp,purchase,sale_management"

# A fixed Odoo 19.0 commit, so that everyone gets the same code.
ODOO_COMMIT = "edceef7991b19796b21debf9819f532a33778f87"
ODOO_URL = f"https://github.com/odoo/odoo/archive/{ODOO_COMMIT}.tar.gz"

# Portable PostgreSQL 18.6, with each file's checksum.
POSTGRES_VERSION = "18.6.0"
POSTGRES_BUILDS = {
    ("Windows", "x86_64"): ("windows-amd64", "b7ef2d03588e0439f0d0a2250f43905f7464f1e96ace47703ceaf79094198150"),
    ("Linux", "x86_64"): ("linux-amd64", "008ee189eaa7ca2b58bd01dd950291e638b998392cf982297acd4779ec898ac1"),
    ("Linux", "aarch64"): ("linux-arm64v8", "5f54e016723afa6213925a8acb939bac52944b1d348f65c7a20f0cd2928c31be"),
    ("Darwin", "arm64"): ("darwin-arm64v8", "8f6ed6f38195b50a40712ada8b2a12060b6193c1a6977a6eb5cff053bb5a1b89"),
    ("Darwin", "x86_64"): ("darwin-amd64", "690941008aac9ee360820fde9bb7870a4f3dcac5e9e2f9e45e42333a436ad0f9"),
}

MAX_WINDOWS_ODOO_PATH = 100

TOOLS = Path(__file__).resolve().parent
COURSE_DIR = TOOLS.parent.parent
RUNTIME = TOOLS / "runtime"
DATA = TOOLS / "data"
PYTHON_DIR = RUNTIME / "python"
ODOO_DIR = RUNTIME / "odoo"
POSTGRES_DIR = RUNTIME / "postgres"
DOWNLOADS = RUNTIME / "downloads"
CONSTRAINTS = TOOLS / "constraints.txt"
REQUIREMENTS = RUNTIME / "requirements-lab.txt"
CONF = DATA / "odoo.conf"
LOGIN_FILE = DATA / "lab-login.txt"
DB_ADMIN_FILE = DATA / "postgres-admin.txt"
PGDATA = DATA / "pgdata"
ODOO_FILES = DATA / "odoo-files"
LOGS = DATA / "logs"
RESULTS = DATA / "results"

WINDOWS = os.name == "nt"
SYSTEM = {"AMD64": "x86_64", "x86_64": "x86_64", "arm64": "arm64", "aarch64": "aarch64"}.get(platform.machine(), platform.machine())
LAUNCHER = "tools\\windows\\odoo"
INTERACTIVE = sys.stdout.isatty()

COLOURS = {"OK": "32", "WARN": "33", "FAIL": "31", "INFO": "36"}
if INTERACTIVE and WINDOWS:
    os.system("")  # turns on colour codes in a Windows console
failures = 0


def say(level, text):
    global failures
    failures += level == "FAIL"
    label = f"[{level:<4}]"
    if INTERACTIVE:
        label = f"\033[{COLOURS[level]}m{label}\033[0m"
    print(f"{label} {text}", flush=True)


def heading(text):
    print(f"\n== {text}", flush=True)


def stop(text):
    say("FAIL", text)
    print("Fix this, then try again. Help: ODOO-SETUP.md, under Troubleshooting.", flush=True)
    sys.exit(1)


def long_path(path):
    """Some Odoo files have paths past Windows' usual limit."""
    return "\\\\?\\" + str(path) if WINDOWS else str(path)


def remove_tree(path):
    if path.exists():
        shutil.rmtree(long_path(path), ignore_errors=True)


def clean_env():
    """Only what is in the tools folder: nothing from the computer's Python or settings."""
    env = {k: v for k, v in os.environ.items()
           if not k.startswith(("PYTHON", "PIP_", "CONDA", "PG", "VIRTUAL_ENV"))}
    bin_folder = PYTHON_DIR if WINDOWS else PYTHON_DIR / "bin"
    parts = [str(bin_folder), str(POSTGRES_DIR / "bin")]
    if WINDOWS:
        parts.append(str(PYTHON_DIR / "Scripts"))
    env["PATH"] = os.pathsep.join(parts + [os.environ.get("PATH", "")])
    # No pip cache: it would leave copies outside tools, and inside tools its deep folders
    # pass Windows' path limit when pip builds the packages published only as source.
    env.update(PYTHONUTF8="1", PYTHONNOUSERSITE="1", PIP_NO_CACHE_DIR="1", PIP_CONFIG_FILE=os.devnull,
               PIP_NO_WARN_SCRIPT_LOCATION="1", PIP_DISABLE_PIP_VERSION_CHECK="1", PIP_NO_INPUT="1",
               ODOO_LAB_LOGIN_FILE=str(LOGIN_FILE))
    return env


def is_ready():
    return CONF.exists() and LOGIN_FILE.exists() and (ODOO_DIR / "odoo-bin").exists() and (PGDATA / "PG_VERSION").exists()


def need_ready():
    if not is_ready():
        stop(f"Odoo is not set up yet. Run: {LAUNCHER} setup")


# ------------------------------------------------------------------ downloads
def download(url, target, sha256=None):
    target.parent.mkdir(parents=True, exist_ok=True)
    request = urllib.request.Request(url, headers={"User-Agent": "utp-ta-labs-setup"})
    context = None
    with contextlib.suppress(ImportError):
        import ssl

        import certifi  # this Python may not know where the computer keeps its certificates
        context = ssl.create_default_context(cafile=certifi.where())
    digest = hashlib.sha256()
    partial = target.with_name(target.name + ".part")
    done = 0
    try:
        with urllib.request.urlopen(request, timeout=60, context=context) as response, partial.open("wb") as out:
            while True:
                block = response.read(1 << 20)
                if not block:
                    break
                out.write(block)
                digest.update(block)
                done += len(block)
                if INTERACTIVE:
                    print(f"\r       {done / (1 << 20):.0f} MB", end="", flush=True)
    except OSError as error:
        partial.unlink(missing_ok=True)
        stop(f"Could not download {url}: {error}. Check your internet connection.")
    if INTERACTIVE:
        print(f"\r{'':<30}\r", end="", flush=True)
    if sha256 and digest.hexdigest() != sha256:
        partial.unlink(missing_ok=True)
        stop(f"{url} did not match its expected checksum, so it was not used.")
    partial.replace(target)


# ------------------------------------------------------------------ Python packages
def pip_install(env, *arguments):
    """Runs pip, showing one line of progress, and its full output only if it fails."""
    process = subprocess.Popen([sys.executable, "-m", "pip", "install", *arguments], stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, env=env, text=True, encoding="utf-8", errors="replace")
    lines, installed = [], None
    for line in process.stdout:
        lines.append(line)
        if line.startswith("Collecting ") and INTERACTIVE:
            print(f"\r       {line.split()[1][:60]:<60}", end="", flush=True)
        elif line.startswith("Successfully installed "):
            installed = len(line.split()) - 2
    code = process.wait()
    if INTERACTIVE:
        print(f"\r{'':<68}\r", end="", flush=True)
    if code:
        useful = [l for l in lines if not l.startswith(("Ignoring ", "Requirement already satisfied"))]
        print("".join(useful[-40:]), end="", flush=True)
    elif installed:
        say("INFO", f"pip installed {installed} package{'' if installed == 1 else 's'}")
    return code


def write_lab_requirements():
    """Odoo's own list, with the two packages that would need a compiler changed.

    psycopg2-binary is the same module as psycopg2, built ready to use. python-ldap is
    needed only for signing in through a company directory, which the labs do not use.
    """
    lines = []
    for raw in (ODOO_DIR / "requirements.txt").read_text(encoding="utf-8").splitlines():
        code = raw.split("#")[0].strip()
        if re.match(r"(?i)python-ldap\b", code):
            continue
        lines.append(re.sub(r"(?i)^psycopg2\b", "psycopg2-binary", code))
    REQUIREMENTS.write_text("\n".join(l for l in lines if l) + "\n", encoding="utf-8")


def setup_odoo_code():
    if (ODOO_DIR / "odoo-bin").exists():
        say("OK", f"already here: {ODOO_DIR}")
        return
    archive = DOWNLOADS / "odoo-19.0.tar.gz"
    if not archive.exists():
        say("INFO", "Downloading Odoo 19 (several hundred MB, so this can take a while)")
        download(ODOO_URL, archive)
    say("INFO", "Unpacking Odoo (a few minutes)")
    temporary = RUNTIME / "odoo.tmp"
    remove_tree(temporary)
    skip = re.compile(r"^(doc/|(odoo/)?addons/[^/]+/tests/)")  # not needed to run, and the longest paths
    with tarfile.open(archive, "r:gz") as source:
        for member in source:
            relative = member.name.split("/", 1)[1] if "/" in member.name else ""
            if not relative or not member.isfile() or skip.match(relative):
                continue
            target = temporary / relative
            os.makedirs(long_path(target.parent), exist_ok=True)
            with source.extractfile(member) as data, open(long_path(target), "wb") as out:
                shutil.copyfileobj(data, out)
    os.replace(long_path(temporary), long_path(ODOO_DIR))
    archive.unlink(missing_ok=True)
    say("OK", f"unpacked to {ODOO_DIR}")


def setup_packages(env):
    say("INFO", "Installing pip's tools")
    if pip_install(env, "--quiet", "setuptools", "wheel", "packaging", "certifi", "-c", str(CONSTRAINTS)):
        stop("pip could not install its tools. Check your internet connection.")


def setup_requirements(env):
    write_lab_requirements()
    say("INFO", "Installing Odoo's packages (a few minutes)")
    # --prefer-binary, not --only-binary: ofxparse is published only as source.
    if pip_install(env, "--prefer-binary", "-r", str(REQUIREMENTS), "-c", str(CONSTRAINTS)):
        stop("pip could not install Odoo's packages. Read its messages above.")
    say("OK", "packages are installed")


# ------------------------------------------------------------------ PostgreSQL
def pg_tool(name):
    return str(POSTGRES_DIR / "bin" / (name + (".exe" if WINDOWS else "")))


def setup_postgres_program():
    if Path(pg_tool("pg_ctl")).exists():
        say("OK", f"already here: {POSTGRES_DIR}")
        return
    build = POSTGRES_BUILDS.get((platform.system(), SYSTEM))
    if not build:
        stop(f"There is no ready-made PostgreSQL here for {platform.system()} {SYSTEM}.")
    name, sha256 = build
    url = (f"https://repo1.maven.org/maven2/io/zonky/test/postgres/embedded-postgres-binaries-{name}/"
           f"{POSTGRES_VERSION}/embedded-postgres-binaries-{name}-{POSTGRES_VERSION}.jar")
    archive = DOWNLOADS / "postgres.jar"
    say("INFO", f"Downloading PostgreSQL {POSTGRES_VERSION}")
    download(url, archive, sha256)
    temporary = RUNTIME / "postgres.tmp"
    remove_tree(temporary)
    temporary.mkdir(parents=True)
    with zipfile.ZipFile(archive) as jar:
        member = next(n for n in jar.namelist() if n.endswith(".txz"))
        with tarfile.open(fileobj=io.BytesIO(jar.read(member)), mode="r:xz") as source:
            source.extractall(temporary, filter="data")
    temporary.replace(POSTGRES_DIR)
    archive.unlink(missing_ok=True)
    say("OK", f"unpacked to {POSTGRES_DIR}")


def setup_cluster(env):
    if (PGDATA / "PG_VERSION").exists():
        say("OK", f"database folder already here: {PGDATA}")
        return
    if not WINDOWS and os.geteuid() == 0:
        stop("PostgreSQL refuses to run as root. Run this as your normal user.")
    DATA.mkdir(parents=True, exist_ok=True)
    if not DB_ADMIN_FILE.exists():
        write_secret(DB_ADMIN_FILE, secrets.token_urlsafe(24))
    remove_tree(PGDATA)
    say("INFO", "Creating the database folder")
    done = subprocess.run([pg_tool("initdb"), "-D", str(PGDATA), "-U", "postgres", "-E", "UTF8", "--locale=C",
                           "--auth=scram-sha-256", f"--pwfile={DB_ADMIN_FILE}"], env=env,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors="replace")
    if done.returncode:
        remove_tree(PGDATA)
        print(done.stdout, flush=True)
        stop("PostgreSQL could not create its database folder. Read the messages above.")
    # Only reachable from this computer, on its own port, with no socket file on disk.
    with (PGDATA / "postgresql.conf").open("a", encoding="utf-8") as conf:
        conf.write(f"\nlisten_addresses = '127.0.0.1'\nport = {DB_PORT}\nunix_socket_directories = ''\n")
    say("OK", f"created {PGDATA}")


def write_secret(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(value + "\n", encoding="ascii")
    if not WINDOWS:
        path.chmod(0o600)


def db_listening():
    with socket.socket() as probe:
        probe.settimeout(1)
        return probe.connect_ex(("127.0.0.1", DB_PORT)) == 0


def start_database(env):
    """Returns True if this call started it, so that the caller knows to stop it."""
    if db_listening():
        return False
    LOGS.mkdir(parents=True, exist_ok=True)
    flags = {"creationflags": subprocess.CREATE_NEW_PROCESS_GROUP} if WINDOWS else {"start_new_session": True}
    # No pipes here: the server would inherit them, and this call would never return.
    code = subprocess.run([pg_tool("pg_ctl"), "-D", str(PGDATA), "-l", str(LOGS / "postgres.log"), "-w", "-t", "60", "start"],
                          env=env, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, **flags).returncode
    if code or not db_listening():
        log = LOGS / "postgres.log"
        if log.exists():
            print("".join(log.read_text(encoding="utf-8", errors="replace").splitlines(True)[-15:]), flush=True)
        stop(f"The database did not start. Its log is {log}")
    return True


def stop_database(env):
    subprocess.run([pg_tool("pg_ctl"), "-D", str(PGDATA), "-m", "fast", "-w", "-t", "60", "stop"], env=env,
                   stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


@contextlib.contextmanager
def database_running(env):
    started = start_database(env)
    try:
        yield
    finally:
        if started:
            stop_database(env)


def connect(database="postgres", admin=False):
    import psycopg2

    if admin:
        return psycopg2.connect(host="127.0.0.1", port=DB_PORT, user="postgres", dbname=database, connect_timeout=10,
                                password=DB_ADMIN_FILE.read_text(encoding="ascii").strip())
    parser = configparser.RawConfigParser()
    parser.read(CONF, encoding="utf-8")
    return psycopg2.connect(host="127.0.0.1", port=DB_PORT, user=parser["options"]["db_user"], dbname=database,
                            password=parser["options"]["db_password"], connect_timeout=10)


def setup_role(env):
    """Odoo refuses to run as the database superuser, so it gets its own role."""
    if CONF.exists():
        say("OK", f"connection settings already here: {CONF}")
        return
    password = secrets.token_urlsafe(24)
    with database_running(env):
        connection = connect(admin=True)
        connection.autocommit = True
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1 FROM pg_roles WHERE rolname = %s", (DB_USER,))
            verb = "ALTER" if cursor.fetchone() else "CREATE"
            cursor.execute(f"{verb} ROLE {DB_USER} LOGIN CREATEDB NOSUPERUSER PASSWORD %s", (password,))
        connection.close()
    lines = ["[options]", "db_host = 127.0.0.1", f"db_port = {DB_PORT}", f"db_user = {DB_USER}",
             f"db_password = {password}", f"admin_passwd = {secrets.token_hex(16)}"]
    write_secret(CONF, "\n".join(lines))
    say("OK", f"created the '{DB_USER}' role, with its settings in {CONF}")


# ------------------------------------------------------------------ Odoo commands
def odoo_arguments():
    addons = ",".join(str(p) for p in (ODOO_DIR / "odoo" / "addons", ODOO_DIR / "addons"))
    return ["-c", str(CONF), f"--addons-path={addons}", f"--data-dir={ODOO_FILES}"]


def server_arguments(args):
    return [*odoo_arguments(), f"--logfile={LOGS / 'odoo.log'}", "--log-level=info",
            "-d", args.database, f"--db-filter=^{args.database}$"]


def odoo_bin():
    return str(ODOO_DIR / "odoo-bin")


def results_dir(args):
    path = Path(args.results) if args.results else RESULTS
    path.mkdir(parents=True, exist_ok=True)
    LOGS.mkdir(parents=True, exist_ok=True)
    ODOO_FILES.mkdir(parents=True, exist_ok=True)
    return path


def database_exists(name):
    connection = connect()
    with connection.cursor() as cursor:
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (name,))
        found = cursor.fetchone() is not None
    connection.close()
    return found


def port_in_use(port):
    with socket.socket() as probe:
        probe.settimeout(1)
        return probe.connect_ex(("127.0.0.1", port)) == 0


def create_lab_database(args, env):
    results_dir(args)
    if not LOGIN_FILE.exists():
        # Generated once. It is never Odoo's default of admin/admin.
        write_secret(LOGIN_FILE, secrets.token_urlsafe(18))
    password = LOGIN_FILE.read_text(encoding="ascii").strip()
    create = [sys.executable, odoo_bin(), "db", "-c", str(CONF), odoo_arguments()[2], "-D", str(ODOO_FILES),
              "init", args.database, "--country", "MY", "--language", "en_US", "--password", password]
    done = subprocess.run(create, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors="replace")
    if done.returncode or not database_exists(args.database):
        print(done.stdout[-3000:], flush=True)
        stop("The lab database could not be created. Read the messages above.")
    apps = [sys.executable, odoo_bin(), *server_arguments(args), "-i", APPS, "--stop-after-init", "--no-http", "--max-cron-threads=0"]
    if subprocess.run(apps, env=env).returncode:
        stop(f"The app install failed. See {LOGS / 'odoo.log'}")


def cmd_setup(args):
    # Odoo's longest file path is 144 characters, and Windows limits a whole path to 260.
    if WINDOWS and len(str(ODOO_DIR)) > MAX_WINDOWS_ODOO_PATH:
        stop(f"This folder is too deep for Windows: {COURSE_DIR}\n"
             "       Move it closer to the drive, for example to C:\\ERP, then delete tools\\windows\\runtime and try again.")
    env = clean_env()
    heading("Step 1 of 6: Python")
    verify_python()
    setup_packages(env)

    heading("Step 2 of 6: Odoo 19")
    setup_odoo_code()

    heading("Step 3 of 6: Odoo's Python packages")
    setup_requirements(env)

    heading("Step 4 of 6: PostgreSQL")
    setup_postgres_program()
    setup_cluster(env)
    setup_role(env)

    heading("Step 5 of 6: verify everything together")
    with database_running(env):
        verify_all(args)
        if failures:
            stop("Verification failed; see the [FAIL] lines above.")

        heading(f"Step 6 of 6: lab database '{args.database}'")
        if database_exists(args.database):
            say("OK", "already exists, so it was left as it is")
        else:
            say("INFO", "Creating it and installing the eight course apps (a few minutes)")
            create_lab_database(args, env)
            say("OK", "created")
        if not LOGIN_FILE.exists():
            write_secret(LOGIN_FILE, secrets.token_urlsafe(18))

    print(flush=True)
    say("OK", f"Setup finished. Everything is in {TOOLS}")
    say("OK", f"Next: {LAUNCHER} start")


def cmd_check(args):
    env = clean_env()
    verify_python()
    if not (ODOO_DIR / "odoo-bin").exists():
        say("WARN", f"Odoo is not here yet. To set it up: {LAUNCHER} setup")
        return
    if not (PGDATA / "PG_VERSION").exists() or not CONF.exists():
        say("WARN", f"PostgreSQL is not set up yet. To set it up: {LAUNCHER} setup")
        verify_packages()
        sys.exit(1 if failures else 0)
    try:
        importlib.import_module("psycopg2")
    except ImportError:
        say("WARN", f"Odoo's packages are not installed yet. To install them: {LAUNCHER} setup")
        return
    with database_running(env):
        verify_all(args)
    print(flush=True)
    say("FAIL" if failures else "OK", f"{failures} problem(s) found. To repair: {LAUNCHER} setup" if failures else "Everything is working.")
    sys.exit(1 if failures else 0)


def cmd_init(args):
    need_ready_for_init()
    env = clean_env()
    with database_running(env):
        create_lab_database(args, env)
    say("OK", f"Database {args.database} is ready. To see the password: {LAUNCHER} login")


def need_ready_for_init():
    if not (CONF.exists() and (ODOO_DIR / "odoo-bin").exists() and (PGDATA / "PG_VERSION").exists()):
        stop(f"Odoo is not set up yet. Run: {LAUNCHER} setup")


def cmd_start(args):
    need_ready()
    if port_in_use(args.port):
        stop(f"Port {args.port} is already in use. If Odoo is running, open http://localhost:{args.port}")
    env = clean_env()
    results_dir(args)
    url = f"http://localhost:{args.port}"
    started = start_database(env)
    say("INFO", f"Odoo is starting at {url}")
    say("INFO", f"Sign in as admin. To see the password: {LAUNCHER} login")
    say("INFO", "The first page takes about a minute and may look blank; wait and reload.")
    say("INFO", "Keep this window open. Press Ctrl+C to stop Odoo.")
    say("INFO", f"Log: {LOGS / 'odoo.log'}")
    if INTERACTIVE and not args.no_browser:
        def open_when_ready():
            for _ in range(180):
                if port_in_use(args.port):
                    webbrowser.open(url)
                    return
                time.sleep(1)
        threading.Thread(target=open_when_ready, daemon=True).start()
    # --limit-time-real=0: Odoo times each connection from when it opens, so a browser tab
    # left idle for 120 s, or a long app install, would otherwise make it exit.
    command = [sys.executable, odoo_bin(), *server_arguments(args), f"--http-port={args.port}", "--http-interface=127.0.0.1",
               "--gevent-port=0", "--max-cron-threads=1", "--limit-time-real=0"]
    code = 0
    try:
        code = subprocess.run(command, env=env).returncode
    except KeyboardInterrupt:
        print("\nStopping...", flush=True)
    finally:
        if started:
            stop_database(env)
    sys.exit(code)


def cmd_stop(args):
    if not (PGDATA / "PG_VERSION").exists() or not db_listening():
        say("OK", "The database is not running.")
        return
    if port_in_use(args.port):
        stop(f"Odoo is still running on port {args.port}. Press Ctrl+C in its window first.")
    stop_database(clean_env())
    say("OK", "The database has stopped.")


def cmd_shell(args):
    need_ready()
    env = clean_env()
    results_dir(args)
    with database_running(env):
        code = subprocess.run([sys.executable, odoo_bin(), "shell", *server_arguments(args), "--max-cron-threads=0"], env=env).returncode
    sys.exit(code)


def cmd_run(args):
    need_ready()
    script = Path(args.script)
    if not script.exists():
        stop(f"{script} not found.")
    env = clean_env()
    env["ODOO_LAB_RESULTS"] = str(results_dir(args))
    with database_running(env), script.open("rb") as source:  # the Odoo shell runs what it reads on stdin
        code = subprocess.run([sys.executable, odoo_bin(), "shell", *server_arguments(args), "--max-cron-threads=0"],
                              stdin=source, env=env).returncode
    if code:
        stop(f"The script failed. See {LOGS / 'odoo.log'}")


def cmd_reset(args):
    # Only *_labs names are accepted, so this can never remove a database built by hand.
    if not args.database.endswith("_labs"):
        stop(f"reset only works on a database named *_labs, not '{args.database}'.")
    if port_in_use(args.port):
        stop(f"Odoo is running on port {args.port}. Press Ctrl+C in its window first.")
    need_ready_for_init()
    env = clean_env()
    results_dir(args)
    with database_running(env):
        code = subprocess.run([sys.executable, odoo_bin(), "db", "-c", str(CONF), odoo_arguments()[2], "-D", str(ODOO_FILES),
                               "drop", args.database], env=env, stdout=subprocess.DEVNULL).returncode
    if code:
        stop(f"Could not delete {args.database}.")
    say("OK", f"Deleted {args.database}. To create it again: {LAUNCHER} init")


def cmd_login(args):
    if not LOGIN_FILE.exists():
        stop(f"Nothing is set up yet. Run: {LAUNCHER} setup")
    print(f"Web address:  http://localhost:{args.port}")
    print("Login:        admin")
    print(f"Password:     {LOGIN_FILE.read_text(encoding='ascii').strip()}")
    print("\nRole logins, once the labs' users exist, use the same password:")
    print("  sales.manager, purchasing.officer, production.planner, accountant, hr.officer")


def cmd_status(args):
    print(f"Set up:    {'yes' if is_ready() else 'not yet'}")
    print(f"Python:    {sys.executable}")
    print(f"Odoo:      {ODOO_DIR if (ODOO_DIR / 'odoo-bin').exists() else 'not here yet'}")
    print(f"Database:  {args.database}, in {PGDATA}, port {DB_PORT} ({'running' if db_listening() else 'stopped'})")
    print(f"Server:    {'running at' if port_in_use(args.port) else 'not running at'} http://localhost:{args.port}")
    print(f"Log:       {LOGS / 'odoo.log'}")


def cmd_menu(args):
    items = [("Set up or repair everything", "setup"),
             ("Start Odoo and open the browser", "start"),
             ("Show the web address and password", "login"),
             ("Check that everything is working", "check"),
             ("Show where everything is", "status"),
             ("Delete the lab database and create it again", "recreate")]
    here = str(Path(__file__).resolve())

    def run(*command):
        try:
            subprocess.run([sys.executable, "-I", here, *command])
        except KeyboardInterrupt:
            pass  # Ctrl+C has stopped Odoo; go back to the menu

    while True:
        print("\n  Odoo 19 for the ERP practicals")
        if not is_ready():
            print("  Not set up yet: choose 1. It downloads everything into the tools folder.\n")
        elif port_in_use(args.port):
            print(f"  Running at http://localhost:{args.port}\n")
        else:
            print("  Ready. Choose 2 to start Odoo.\n")
        for number, (label, _) in enumerate(items, 1):
            print(f"  {number}  {label}")
        print("  0  Exit\n")
        try:
            choice = input("  Choose a number: ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            return
        if choice in ("0", "q", "exit"):
            return
        if not choice.isdigit() or not 1 <= int(choice) <= len(items):
            print("  Please type a number from the list.")
            continue
        command = items[int(choice) - 1][1]
        print(flush=True)
        if command == "recreate":
            try:
                answer = input(f"  This deletes everything in {args.database}. Type yes to continue: ").strip()
            except (EOFError, KeyboardInterrupt):
                answer = ""
            if answer.lower() != "yes":
                print("  Cancelled; nothing was changed.")
                continue
            run("reset")
            run("init")
        else:
            run(command)


# ------------------------------------------------------------------ verification
def inside_tools(path):
    return os.path.normcase(os.path.abspath(path)).startswith(os.path.normcase(str(TOOLS)))


def verify_python():
    label = f"Python {sys.version.split()[0]} ({64 if sys.maxsize > 2**32 else 32}-bit)"
    if sys.version_info[:2] != PYTHON:
        say("FAIL", f"{label}: this course needs Python {PYTHON[0]}.{PYTHON[1]}. Delete tools\\windows\\runtime and start again.")
    else:
        say("OK", label)
    if inside_tools(sys.prefix):
        say("OK", f"private to the tools folder: {sys.prefix}")
    else:
        stop(f"This is running with {sys.executable}, not the tools folder's own Python. Use the launcher: {LAUNCHER}")


def verify_packages():
    from packaging.requirements import InvalidRequirement, Requirement
    from packaging.utils import canonicalize_name

    dists = list(metadata.distributions())
    foreign = sorted({d.metadata["Name"] for d in dists if not inside_tools(str(d.locate_file("")))})
    if foreign:
        say("FAIL", "packages from outside the tools folder: " + ", ".join(foreign))
    else:
        say("OK", "every package comes from inside the tools folder")
    user_site = Path(site.getusersitepackages())
    if site.ENABLE_USER_SITE and user_site.is_dir():
        say("WARN", f"Python could read {user_site}. Use the launcher, which turns that off.")

    missing, different, checked, skipped = [], [], 0, 0
    if not REQUIREMENTS.exists():
        write_lab_requirements()
    for line in REQUIREMENTS.read_text(encoding="utf-8").splitlines():
        try:
            requirement = Requirement(line)
        except InvalidRequirement:
            continue
        if requirement.marker and not requirement.marker.evaluate():
            skipped += 1
            continue
        checked += 1
        try:
            version = metadata.version(requirement.name)
        except metadata.PackageNotFoundError:
            missing.append(requirement.name)
            continue
        if requirement.specifier and version not in requirement.specifier:
            different.append(f"{requirement.name} {version} (Odoo pins {requirement.specifier})")
    if missing:
        say("FAIL", f"missing packages: {', '.join(missing)}. Repair with: {LAUNCHER} setup")
    if different:
        say("WARN", "packages differ from Odoo's pins: " + "; ".join(different))
    if not missing and not different:
        say("OK", f"all {checked} packages Odoo needs on this system are at its pinned versions")

    locked = {}
    for raw in CONSTRAINTS.read_text(encoding="utf-8").splitlines():
        line = raw.split("#")[0].strip()
        if "==" in line:
            name, version = line.split("==", 1)
            locked[canonicalize_name(name)] = version.strip()
    installed = {canonicalize_name(d.metadata["Name"]): d.version for d in dists}
    windows_only = {"colorama", "pywin32", "pypiwin32", "rl-renderpm"}
    expected = {n: v for n, v in locked.items() if WINDOWS or n not in windows_only}
    absent = sorted(set(expected) - set(installed))
    wrong = [f"{n} {installed[n]} (locked {expected[n]})" for n in sorted(expected) if n in installed and installed[n] != expected[n]]
    if absent or wrong:
        parts = (["missing " + ", ".join(absent)] if absent else []) + (["different " + ", ".join(wrong)] if wrong else [])
        say("WARN", "not the known-good set: " + "; ".join(parts))
    else:
        say("OK", f"all {len(expected)} packages match the known-good versions in {CONSTRAINTS.name}")

    names = ["lxml", "lxml.html.clean", "psycopg2", "PIL", "reportlab", "cryptography", "OpenSSL", "sass", "rjsmin", "cbor2"]
    names += ["win32api"] if WINDOWS else ["gevent"]
    # In a new process: this one started before the packages were installed, and
    # pywin32 only sets up its import paths when Python starts.
    code = ("import importlib, json, sys\n"
            "broken = []\n"
            "for name in sys.argv[1:]:\n"
            "    try:\n"
            "        where = getattr(importlib.import_module(name), '__file__', None) or ''\n"
            "        if where and not where.lower().startswith(sys.prefix.lower()):\n"
            "            broken.append(f'{name} (loaded from {where})')\n"
            "    except Exception as error:\n"
            "        broken.append(f'{name} ({error})')\n"
            "print(json.dumps(broken))\n")
    done = subprocess.run([sys.executable, "-I", "-c", code, *names], capture_output=True, text=True, env=clean_env())
    broken = json.loads(done.stdout.strip().splitlines()[-1]) if done.returncode == 0 and done.stdout.strip() else [done.stderr.strip()]
    if broken:
        say("FAIL", "cannot load: " + "; ".join(broken))
    else:
        say("OK", "compiled packages load from the tools folder")


def verify_all(args):
    env = clean_env()
    verify_packages()

    result = subprocess.run([sys.executable, odoo_bin(), "--version"], capture_output=True, text=True,
                            timeout=180, cwd=ODOO_DIR, env=env)
    if result.returncode:
        lines = (result.stderr or result.stdout).strip().splitlines()
        say("FAIL", "this Python cannot start Odoo: " + (lines[-1] if lines else "no message"))
    else:
        say("OK", f"this Python starts {result.stdout.strip()}, from the tools folder")

    try:
        connection = connect()
    except Exception as error:
        say("FAIL", f"cannot connect to the private database: {str(error).strip().splitlines()[0]}")
        return
    admin = connect(admin=True)
    with admin.cursor() as cursor:
        cursor.execute("SHOW data_directory")  # only the database's administrator may read this
        where = cursor.fetchone()[0]
    admin.close()
    with connection.cursor() as cursor:
        cursor.execute("SHOW server_version")
        version = cursor.fetchone()[0]
        cursor.execute("SELECT rolcreatedb, rolsuper FROM pg_roles WHERE rolname = current_user")
        createdb, superuser = cursor.fetchone()
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = %s", (args.database,))
        exists = cursor.fetchone() is not None
    connection.close()
    if inside_tools(where):
        say("OK", f"PostgreSQL {version}, private to the tools folder, on port {DB_PORT}")
    else:
        say("FAIL", f"port {DB_PORT} is answered by another PostgreSQL, with its data in {where}")
    say("OK" if createdb and not superuser else "FAIL", f"the '{DB_USER}' role can create databases and is not a superuser")
    say("OK" if exists else "INFO", f"lab database '{args.database}' {'exists' if exists else 'does not exist yet'}")


# ------------------------------------------------------------------ command line
def main():
    sys.stdout.reconfigure(errors="replace")  # a console may lack some of pip's characters
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", metavar="command")

    def add(name, handler, text):
        sub = commands.add_parser(name, help=text, description=text)
        sub.set_defaults(handler=handler)
        sub.add_argument("--database", default=DATABASE, help=f"lab database (default {DATABASE})")
        sub.add_argument("--port", type=int, default=PORT, help=f"web port (default {PORT})")
        sub.add_argument("--results", help="folder for the labs' evidence (default tools\\windows\\data\\results)")
        return sub

    add("setup", cmd_setup, "download and set up everything, or repair what is missing")
    add("start", cmd_start, "start the database and Odoo, and open the browser").add_argument(
        "--no-browser", action="store_true", help="do not open the browser")
    add("stop", cmd_stop, "stop the database if it was left running")
    add("login", cmd_login, "show the web address and sign-in details")
    add("check", cmd_check, "report on everything; change nothing")
    add("status", cmd_status, "show where everything is, and what is running")
    add("shell", cmd_shell, "open a Python shell inside Odoo")
    add("run", cmd_run, "run a script inside Odoo").add_argument("script")
    add("init", cmd_init, "create the lab database")
    add("reset", cmd_reset, "delete the lab database (names ending _labs only)")
    add("menu", cmd_menu, "show the menu (the default in a terminal)")

    args = parser.parse_args()
    if not args.command:
        if sys.stdin.isatty() and sys.stdout.isatty():
            args = parser.parse_args(["menu"])
        else:
            parser.print_help()
            return
    args.handler(args)


if __name__ == "__main__":
    main()
