"""
Lab 4 checker --- the CRM opportunity and its link to a quotation.

    py check_crm.py --password YOUR_ADMIN_PASSWORD

CRM is the lab most often "completed" by creating an opportunity and
stopping. The point of the lab is the LINK: the customer, owner and
expected revenue recorded before the sale exists must survive into the
quotation. This checks that the link is really there.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_shared"))

from odoo_client import CheckRun, add_connection_args, connect_from_args  # noqa: E402
from west_end_data import CUSTOMER, OPPORTUNITY, SALES_ORDER  # noqa: E402


def main():
    parser = argparse.ArgumentParser(description="Check the Lab 4 CRM build.")
    add_connection_args(parser)
    args = parser.parse_args()
    odoo = connect_from_args(args)

    run = CheckRun(f"Lab 4 --- CRM  (server {odoo.version}, db '{odoo.db}')")

    if not odoo.has_model("crm.lead"):
        print("CRM app is not installed. Install it, then rerun.")
        raise SystemExit(2)

    # ---------------- Part A: the customer ----------------
    customer = odoo.first(
        "res.partner", [("name", "=", CUSTOMER["name"])],
        ["id", "name", "is_company", "city"],
    )
    run.check(
        customer is not None,
        f"Customer exists: {CUSTOMER['name']}",
        hint="Contacts -> New. Choose Company, not Individual --- a cycling club is "
             "an organisation, and the quotation should be addressed to it.",
    )
    if customer:
        run.check(
            customer.get("is_company"),
            "Customer is recorded as a Company",
            hint="Tick Company on the contact form.",
        )

    # ---------------- Part B: the opportunity ----------------
    leads = odoo.search_read(
        "crm.lead",
        [("type", "=", "opportunity")],
        ["id", "name", "partner_id", "expected_revenue", "user_id", "stage_id", "probability"],
        order="id desc",
    )
    run.check(
        bool(leads),
        "A CRM opportunity exists",
        hint="CRM -> New. Name it "
             f"'{OPPORTUNITY['name']}'.",
    )

    ours = None
    if customer:
        for lead in leads:
            partner = lead.get("partner_id")
            if partner and partner[0] == customer["id"]:
                ours = lead
                break

    run.check(
        ours is not None,
        "The opportunity is linked to the customer",
        hint="Set Customer on the opportunity. Without it the opportunity cannot "
             "become a quotation for anybody.",
    )

    if ours:
        run.check(
            abs((ours.get("expected_revenue") or 0) - OPPORTUNITY["expected_revenue"]) < 0.01,
            f"Expected Revenue is RM {OPPORTUNITY['expected_revenue']:,.2f}",
            hint=f"{SALES_ORDER['quantity']} bikes x "
                 f"RM {SALES_ORDER['unit_price']:,.2f}. This is a FORECAST, not revenue "
                 "earned --- say so when you present it.",
            detail=f"found: RM {ours.get('expected_revenue') or 0:,.2f}",
        )
        run.check(
            bool(ours.get("user_id")),
            "A Salesperson owns the opportunity",
            hint="Set Salesperson to the Sales Manager.",
            detail=f"found: {ours['user_id'][1] if ours.get('user_id') else '(none)'}",
        )
        stage = ours.get("stage_id")
        run.check(
            bool(stage),
            "The opportunity sits in a pipeline stage",
            hint="Drag the card through New -> Qualified -> Proposition.",
            detail=f"stage: {stage[1] if stage else '(none)'}",
        )

    # ---------------- Part D: opportunity -> quotation ----------------
    if customer:
        quotations = odoo.search_read(
            "sale.order",
            [("partner_id", "=", customer["id"])],
            ["id", "name", "state", "amount_total", "opportunity_id", "user_id"],
            order="id desc",
        )
        run.check(
            bool(quotations),
            "A quotation exists for the customer",
            hint="Use the opportunity's New Quotation action so the two records stay linked.",
        )

        linked = [q for q in quotations if q.get("opportunity_id")]
        run.check(
            bool(linked),
            "The quotation was created FROM the opportunity (they are linked)",
            hint="A quotation typed separately in Sales works commercially but breaks the "
                 "CRM story: the pipeline can no longer show what the deal became. "
                 "Create it from the opportunity instead.",
            detail=f"{len(linked)} of {len(quotations)} quotation(s) carry an opportunity link",
        )

        if quotations:
            run.check(
                abs(quotations[0]["amount_total"] - SALES_ORDER["total"]) < 0.01,
                f"Quotation total is RM {SALES_ORDER['total']:,.2f}",
                hint=f"Add {SALES_ORDER['quantity']} x {SALES_ORDER['product']} at "
                     f"RM {SALES_ORDER['unit_price']:,.2f}.",
                detail=f"found: RM {quotations[0]['amount_total']:,.2f}",
            )

            # The teaching point: expected revenue and quotation value should
            # agree at this stage, and a gap is worth explaining.
            if ours:
                expected = ours.get("expected_revenue") or 0
                actual = quotations[0]["amount_total"]
                if abs(expected - actual) >= 0.01:
                    print(f"\n  Note: expected revenue RM {expected:,.2f} and quotation "
                          f"RM {actual:,.2f} differ.")
                    print("  That is allowed --- a forecast is not a quotation --- but be "
                          "ready to explain the gap.")

    raise SystemExit(0 if run.report() else 1)


if __name__ == "__main__":
    main()
