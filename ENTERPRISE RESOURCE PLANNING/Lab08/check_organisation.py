"""
Lab 8 checker --- organisation structure, and whether people own real work.

    py check_organisation.py --password YOUR_ADMIN_PASSWORD

Part F of the lab makes the argument that an employee record only means
something when that person owns a transaction. This checker tests exactly
that: for each operational role it looks for a document with an owner set,
and reports the roles that exist on paper but appear nowhere in the
business process.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_shared"))

from odoo_client import CheckRun, add_connection_args, connect_from_args  # noqa: E402
from west_end_data import DEPARTMENTS, EMPLOYEES  # noqa: E402

# role -> (model, owner field, human label for the document)
ROLE_OWNERSHIP = [
    ("Sales Manager",      "sale.order",     "user_id", "a Sales Order"),
    ("Purchasing Officer", "purchase.order", "user_id", "a Purchase Order"),
    ("Production Planner", "mrp.production", "user_id", "a Manufacturing Order"),
]


def main():
    parser = argparse.ArgumentParser(description="Check the Lab 8 organisation data.")
    add_connection_args(parser)
    args = parser.parse_args()
    odoo = connect_from_args(args)

    run = CheckRun(f"Lab 8 --- Organisation  (server {odoo.version}, db '{odoo.db}')")

    if not odoo.has_model("hr.department"):
        print("Employees app is not installed. Install it, then rerun.")
        raise SystemExit(2)

    # ---------------- Part A: structure ----------------
    departments = odoo.search_read(
        "hr.department", [], ["name", "manager_id", "total_employee"]
    )
    by_name = {d["name"]: d for d in departments}

    for wanted in DEPARTMENTS:
        run.check(
            wanted in by_name,
            f"Department exists: {wanted}",
            hint="Employees -> Departments -> New.",
        )

    with_manager = [d for d in departments if d.get("manager_id")]
    run.check(
        len(with_manager) == len(departments) and departments,
        "Every department has a manager",
        hint="An unmanaged department has no one accountable for it.",
        detail=f"{len(with_manager)} of {len(departments)} departments have a manager",
    )

    employees = odoo.search_read("hr.employee", [], ["name", "job_title", "department_id"])
    run.check(
        len(employees) >= len(EMPLOYEES),
        f"At least {len(EMPLOYEES)} employees exist",
        hint="Employees -> New.",
        detail=f"found: {len(employees)}",
    )

    unassigned = [e["name"] for e in employees if not e.get("department_id")]
    run.check(
        not unassigned,
        "Every employee belongs to a department",
        hint="Set Department on each employee record.",
        detail=f"without a department: {', '.join(unassigned) if unassigned else 'none'}",
    )

    # ---------------- Part F: do these people own anything? ----------------
    print()
    print("  Part F --- does each operational role own a real document?")
    print()

    for role, model, field, document in ROLE_OWNERSHIP:
        if not odoo.has_model(model):
            run.skip(
                f"{role} owns {document}",
                f"The app providing {model} is not installed, so this cannot be checked.",
            )
            continue

        owned = odoo.search_read(model, [(field, "!=", False)], [field, "name"])
        owners = sorted({row[field][1] for row in owned if row.get(field)})

        run.check(
            bool(owned),
            f"{role} owns {document}",
            hint=f"Open {document} and set its owner field. An employee who owns no "
                 "document is a name in a list, not a role in a process.",
            detail=f"owners found: {', '.join(owners) if owners else 'none'}",
        )

    # ---------------- employee record vs login ----------------
    users = odoo.search_read(
        "res.users", [("active", "=", True), ("share", "=", False)], ["name", "login"]
    )
    employee_names = {e["name"] for e in employees}
    user_names = {u["name"] for u in users}
    both = employee_names & user_names

    run.check(
        bool(both),
        "At least one employee also has a login",
        hint="Settings -> Users & Companies -> Users. Ownership fields such as "
             "Salesperson and Buyer point at USERS, not at HR employee records, so a "
             "person with no login cannot own a transaction.",
        detail=f"employees who are also users: {', '.join(sorted(both)) if both else 'none'}",
    )

    print()
    print("  The distinction the deliverable asks you to explain:")
    print("    an hr.employee record  describes a person the organisation employs;")
    print("    a res.users record     is an identity that can log in and own documents.")
    print("  Odoo keeps them separate because most employees never need a login,")
    print("  and some logins (integrations, portals) are not employees at all.")

    raise SystemExit(0 if run.report() else 1)


if __name__ == "__main__":
    main()
