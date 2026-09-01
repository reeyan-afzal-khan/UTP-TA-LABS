"""
Capstone checker --- the whole West End Bicycles story, in one pass.

    py check_capstone.py --password YOUR_ADMIN_PASSWORD

Each lab checker looks at one stage. This one follows the two cycles the
capstone chapter describes and, critically, checks the STOCK ARITHMETIC
that ties them together:

    buy -> receive        raw material stock rises
    manufacture           components fall by the BOM, bikes rise
    deliver               bikes fall

If the bought, built and sold quantities all match the plan, every product
ends on zero. A non-zero balance is not a rounding problem --- it means a
step was skipped or a quantity was mistyped, and the report says which.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from odoo_client import CheckRun, add_connection_args, connect_from_args  # noqa: E402
from west_end_data import (  # noqa: E402
    BOM_ROAD_BIKE,
    CUSTOMER,
    MANUFACTURE_QTY,
    PURCHASE_QUANTITIES,
    RAW_MATERIALS,
    SALES_ORDER,
    expected_component_consumption,
    stock_after_full_cycle,
)


def stage(odoo, run, label, model, domain, hint):
    """One document must exist in a finished state for the story to continue."""
    if not odoo.has_model(model):
        run.skip(label, f"{model} is unavailable; its app is not installed.")
        return False
    found = odoo.count(model, domain)
    return run.check(found > 0, label, hint=hint, detail=f"{found} matching record(s)")


def main():
    parser = argparse.ArgumentParser(description="Check the full capstone story.")
    add_connection_args(parser)
    args = parser.parse_args()
    odoo = connect_from_args(args)

    run = CheckRun(f"Capstone --- West End Bicycles  (server {odoo.version}, db '{odoo.db}')")

    # ---------------- the buying cycle ----------------
    stage(odoo, run, "Purchase Order confirmed",
          "purchase.order", [("state", "in", ["purchase", "done"])],
          "Purchase -> confirm an RFQ into a Purchase Order.")

    stage(odoo, run, "Receipt validated (raw materials on hand)",
          "stock.picking",
          [("picking_type_id.code", "=", "incoming"), ("state", "=", "done")],
          "Open the Receipt from the PO and Validate it.")

    # ---------------- making ----------------
    stage(odoo, run, f"Bill of Materials for {BOM_ROAD_BIKE['product']}",
          "mrp.bom", [("product_tmpl_id.name", "=", BOM_ROAD_BIKE["product"])],
          "Manufacturing -> Products -> Bills of Materials.")

    stage(odoo, run, "Manufacturing Order Done",
          "mrp.production", [("state", "=", "done")],
          "Confirm the MO and mark it Done; a Confirmed MO has moved nothing.")

    # ---------------- the selling cycle ----------------
    stage(odoo, run, "CRM opportunity exists",
          "crm.lead", [("type", "=", "opportunity")],
          "CRM -> New.")

    stage(odoo, run, "Sales Order confirmed",
          "sale.order", [("state", "in", ["sale", "done"])],
          "Confirm the quotation.")

    stage(odoo, run, "Delivery validated",
          "stock.picking",
          [("picking_type_id.code", "=", "outgoing"), ("state", "=", "done")],
          "Open the Delivery from the Sales Order and Validate it.")

    stage(odoo, run, "Invoice posted",
          "account.move",
          [("move_type", "=", "out_invoice"), ("state", "=", "posted")],
          "Create the invoice from the Sales Order, then Post it.")

    stage(odoo, run, "Payment registered",
          "account.move",
          [("move_type", "=", "out_invoice"),
           ("payment_state", "in", ["paid", "in_payment"])],
          "Register Payment on the posted invoice.")

    # ---------------- the arithmetic that ties it together ----------------
    print()
    print("  Stock reconciliation")
    print("  " + "-" * 68)
    print(f"  {'product':<20}{'bought':>8}{'consumed':>10}{'expected':>10}{'actual':>9}")

    consumption = expected_component_consumption(MANUFACTURE_QTY)
    expected_stock = stock_after_full_cycle(MANUFACTURE_QTY)
    discrepancies = []

    for name, *_ in RAW_MATERIALS:
        bought = PURCHASE_QUANTITIES.get(name, 0)
        used = consumption.get(name, 0)
        expected = expected_stock.get(name, 0)
        actual = odoo.qty_on_hand(name)
        shown = f"{actual:g}" if actual is not None else "n/a"
        print(f"  {name:<20}{bought:>8}{used:>10}{expected:>10}{shown:>9}")
        if actual is not None and abs(actual - expected) > 0.001:
            discrepancies.append((name, expected, actual))

    bikes = odoo.qty_on_hand(BOM_ROAD_BIKE["product"])
    expected_bikes = expected_stock[BOM_ROAD_BIKE["product"]]
    shown = f"{bikes:g}" if bikes is not None else "n/a"
    print(f"  {BOM_ROAD_BIKE['product']:<20}{MANUFACTURE_QTY:>8}"
          f"{SALES_ORDER['quantity']:>10}{expected_bikes:>10}{shown:>9}")
    if bikes is not None and abs(bikes - expected_bikes) > 0.001:
        discrepancies.append((BOM_ROAD_BIKE["product"], expected_bikes, bikes))

    print()
    run.check(
        not discrepancies,
        "On-hand stock matches the planned buy/build/sell quantities",
        hint="A component above plan means it was received but not consumed --- check "
             "the MO is Done. Below plan means more was consumed than bought, so the "
             "BOM quantity or the purchase quantity is wrong. Bikes above zero mean "
             "the Delivery was never validated.",
        detail="; ".join(f"{n}: expected {e:g}, found {a:g}" for n, e, a in discrepancies)
               or "every product lands on its planned figure",
    )

    print()
    print(f"  The story in one line: bought to plan, built {MANUFACTURE_QTY}, "
          f"sold {SALES_ORDER['quantity']} to {CUSTOMER['name']},")
    print(f"  billed RM {SALES_ORDER['total']:,.2f}, and the warehouse is back to zero.")

    raise SystemExit(0 if run.report() else 1)


if __name__ == "__main__":
    main()
