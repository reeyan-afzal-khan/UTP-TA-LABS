"""
A small wrapper over Odoo's External API, used by every lab checker.

Odoo exposes its ORM over XML-RPC on the same port as the web interface.
Nothing here needs a library outside the Python standard library, which is
deliberate --- the labs must run on a lab PC with no pip access.

Two endpoints matter:

    /xmlrpc/2/common   authenticate, version    (no login required)
    /xmlrpc/2/object   execute_kw               (everything else)

`execute_kw(db, uid, password, model, method, args, kwargs)` is the ORM.
Anything the web UI can do, it can do --- which is exactly why the labs use
it to CHECK work rather than to do the work. Build the records through the
interface, then run the checker to prove the result.

Connection settings come from the command line or from environment
variables, so no password is ever written into a lab file:

    ODOO_URL=http://localhost:8069  ODOO_DB=west_end_bicycles
    ODOO_USER=admin                 ODOO_PASSWORD=...
"""

import os
import sys
import xmlrpc.client


class OdooError(RuntimeError):
    pass


class Odoo:
    """One authenticated connection to an Odoo database."""

    def __init__(self, url, db, username, password):
        self.url = url.rstrip("/")
        self.db = db
        self.username = username
        self.password = password

        common = xmlrpc.client.ServerProxy(f"{self.url}/xmlrpc/2/common")
        try:
            self.version = common.version().get("server_serie", "unknown")
        except Exception as exc:                      # network, wrong port, no server
            raise OdooError(
                f"Cannot reach Odoo at {self.url}. Is the server running?\n  {exc}"
            ) from exc

        self.uid = common.authenticate(db, username, password, {})
        if not self.uid:
            raise OdooError(
                f"Login failed for user '{username}' on database '{db}'.\n"
                "Check the database name (it is case sensitive) and the password."
            )
        self.models = xmlrpc.client.ServerProxy(f"{self.url}/xmlrpc/2/object")

    # ------------------------------------------------------------------
    def execute(self, model, method, *args, **kwargs):
        try:
            return self.models.execute_kw(
                self.db, self.uid, self.password, model, method, list(args), kwargs
            )
        except xmlrpc.client.Fault as fault:
            raise OdooError(f"{model}.{method} failed: {fault.faultString}") from fault

    def search_read(self, model, domain=None, fields=None, limit=None, order=None):
        kwargs = {"fields": fields or []}
        if limit:
            kwargs["limit"] = limit
        if order:
            kwargs["order"] = order
        return self.execute(model, "search_read", domain or [], **kwargs)

    def count(self, model, domain=None):
        return self.execute(model, "search_count", domain or [])

    def exists(self, model, domain):
        return self.count(model, domain) > 0

    def first(self, model, domain, fields):
        """The single record matching `domain`, or None."""
        rows = self.search_read(model, domain, fields, limit=1)
        return rows[0] if rows else None

    def module_installed(self, technical_name):
        return self.exists(
            "ir.module.module",
            [("name", "=", technical_name), ("state", "=", "installed")],
        )

    def has_model(self, model):
        """Whether a model exists at all --- an uninstalled app has none."""
        return self.exists("ir.model", [("model", "=", model)])

    def qty_on_hand(self, product_name):
        """Current on-hand quantity for a product, by name.

        Reads product.product rather than product.template: a template with
        variants has no single stock figure, and the labs use simple
        one-variant products.
        """
        row = self.first(
            "product.product",
            [("name", "=", product_name)],
            ["qty_available", "name"],
        )
        return row["qty_available"] if row else None


# ---------------------------------------------------------------------- CLI

def add_connection_args(parser):
    """Attach the four standard connection options to an ArgumentParser."""
    parser.add_argument("--url", default=os.environ.get("ODOO_URL", "http://localhost:8069"),
                        help="Odoo base URL (default http://localhost:8069)")
    parser.add_argument("--db", default=os.environ.get("ODOO_DB", "west_end_bicycles"),
                        help="database name (default west_end_bicycles)")
    parser.add_argument("--user", default=os.environ.get("ODOO_USER", "admin"),
                        help="login (default admin)")
    parser.add_argument("--password", default=os.environ.get("ODOO_PASSWORD"),
                        help="password; or set ODOO_PASSWORD so it stays out of your shell history")
    return parser


def connect_from_args(args):
    """Build an Odoo connection, exiting with a readable message on failure."""
    if not args.password:
        print("No password given. Pass --password or set ODOO_PASSWORD.", file=sys.stderr)
        raise SystemExit(2)
    try:
        return Odoo(args.url, args.db, args.user, args.password)
    except OdooError as exc:
        print(f"\n{exc}\n", file=sys.stderr)
        raise SystemExit(2)


# ------------------------------------------------------------ check reporting

class CheckRun:
    """Collects pass/fail results and prints a readable report.

    A check that fails prints the hint, because a checker that only says
    "FAIL" teaches nothing. The hint should name the Odoo screen to open.
    """

    def __init__(self, title):
        self.title = title
        self.results = []

    def check(self, passed, description, hint="", detail=""):
        self.results.append((bool(passed), description, hint, detail))
        return bool(passed)

    def skip(self, description, reason):
        self.results.append((None, description, reason, ""))

    def report(self):
        width = 74
        print("=" * width)
        print(self.title)
        print("=" * width)

        passed = failed = skipped = 0
        for ok, description, hint, detail in self.results:
            if ok is None:
                mark, skipped = "SKIP", skipped + 1
            elif ok:
                mark, passed = " ok ", passed + 1
            else:
                mark, failed = "FAIL", failed + 1
            print(f"  [{mark}] {description}")
            if detail:
                print(f"           {detail}")
            if ok is not True and hint:
                print(f"           -> {hint}")

        print("-" * width)
        print(f"  {passed} passed, {failed} failed, {skipped} skipped")
        if failed == 0 and skipped == 0:
            print("  Lab complete.")
        elif failed == 0:
            print("  Nothing failed, but some checks could not run (see SKIP).")
        else:
            print("  Work through the -> hints and run this again.")
        print("=" * width)
        return failed == 0
