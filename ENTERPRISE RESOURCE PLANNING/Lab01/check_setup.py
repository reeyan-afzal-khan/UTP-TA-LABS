"""
Lab 1 checker --- is the Odoo foundation actually built?

Build the company, departments, employees and users through the Odoo
interface as the lab sheet describes, then run this to prove it:

    py check_setup.py --password YOUR_ADMIN_PASSWORD

It reads the database and reports one line per lab requirement. Nothing is
created or changed: this is a read-only check, so running it twice is safe.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_shared"))

from odoo_client import CheckRun, add_connection_args, connect_from_args  # noqa: E402
from west_end_data import (  # noqa: E402
    COMPANY,
    DEPARTMENT_MANAGERS,
    DEPARTMENTS,
    EMPLOYEES,
    REQUIRED_APPS,
)


def main():
    parser = argparse.ArgumentParser(description="Check the Lab 1 Odoo setup.")
    add_connection_args(parser)
    args = parser.parse_args()
    odoo = connect_from_args(args)

    run = CheckRun(f"Lab 1 --- Odoo foundation  (server {odoo.version}, db '{odoo.db}')")

    # ---------------- Part C: the eight course apps ----------------
    for technical, label, purpose in REQUIRED_APPS:
        run.check(
            odoo.module_installed(technical),
            f"App installed: {label}",
            hint=f"Apps -> search '{label}' -> Install. Needed for: {purpose}.",
        )

    # ---------------- Part D: company profile ----------------
    company = odoo.first(
        "res.company", [("name", "=", COMPANY["name"])], ["name", "city", "country_id"]
    )
    run.check(
        company is not None,
        f"Company renamed to '{COMPANY['name']}'",
        hint="Settings -> Users & Companies -> Companies -> rename the default company.",
    )
    if company:
        run.check(
            (company.get("city") or "").strip().lower() == COMPANY["city"].lower(),
            f"Company city is {COMPANY['city']}",
            hint=f"Set City to {COMPANY['city']} on the company record.",
            detail=f"found: {company.get('city') or '(blank)'}",
        )
        country = company.get("country_id")
        country_name = country[1] if country else None
        run.check(
            country_name == COMPANY["country"],
            f"Company country is {COMPANY['country']}",
            hint=f"Set Country to {COMPANY['country']} on the company record.",
            detail=f"found: {country_name or '(blank)'}",
        )

    # ---------------- Part D: departments ----------------
    if not odoo.has_model("hr.department"):
        run.skip("Departments created", "Employees app is not installed yet.")
    else:
        existing = {d["name"] for d in odoo.search_read("hr.department", [], ["name"])}
        for wanted in DEPARTMENTS:
            run.check(
                wanted in existing,
                f"Department exists: {wanted}",
                hint="Employees -> Departments -> New.",
            )

        # A department with no manager is the usual half-finished case.
        for dept_name, manager_name in DEPARTMENT_MANAGERS.items():
            dept = odoo.first(
                "hr.department", [("name", "=", dept_name)], ["name", "manager_id"]
            )
            if dept is None:
                run.skip(f"Manager set for {dept_name}", "Department does not exist yet.")
                continue
            manager = dept.get("manager_id")
            run.check(
                bool(manager),
                f"Manager set for {dept_name}",
                hint=f"Open the department and set Manager (suggested: {manager_name}).",
                detail=f"found: {manager[1] if manager else '(none)'}",
            )

    # ---------------- Part D: employees ----------------
    if not odoo.has_model("hr.employee"):
        run.skip("Employees created", "Employees app is not installed yet.")
    else:
        for name, job, dept, _owns in EMPLOYEES:
            employee = odoo.first(
                "hr.employee", [("name", "=", name)], ["name", "job_title", "department_id"]
            )
            run.check(
                employee is not None,
                f"Employee exists: {name} ({job})",
                hint=f"Employees -> New. Job Title '{job}', Department '{dept}'.",
            )

        # The roles matter more than the names --- a class may use its own
        # people, so check that each operational job title is filled by someone.
        titles = {
            (e.get("job_title") or "").strip().lower()
            for e in odoo.search_read("hr.employee", [], ["job_title"])
        }
        for _name, job, _dept, owns in EMPLOYEES:
            run.check(
                job.lower() in titles,
                f"Someone holds the role: {job}",
                hint=f"This role owns: {owns}.",
            )

    # ---------------- Part E: operational logins ----------------
    users = odoo.count("res.users", [("active", "=", True), ("share", "=", False)])
    run.check(
        users >= 2,
        "At least one operational login exists besides the administrator",
        hint="Settings -> Users & Companies -> Users -> New. "
             "An HR employee record is not a login; ownership fields need a user.",
        detail=f"internal users found: {users}",
    )

    raise SystemExit(0 if run.report() else 1)


if __name__ == "__main__":
    main()
