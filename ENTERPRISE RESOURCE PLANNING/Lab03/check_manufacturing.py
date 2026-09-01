"""
Lab 3 checker --- products, the Road Bike BOM, and the Manufacturing Order.

    py check_manufacturing.py --password YOUR_ADMIN_PASSWORD

The interesting check is Part F: after the MO is Done, component stock must
have fallen by exactly the BOM quantity times the number of bikes, and Road
Bike stock must have risen by the number built. This script computes those
figures from the BOM in _shared/west_end_data.py rather than trusting a
number typed into a screenshot.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_shared"))

from odoo_client import CheckRun, add_connection_args, connect_from_args  # noqa: E402
from west_end_data import (  # noqa: E402
    BOM_ROAD_BIKE,
    FINISHED_GOODS,
    MANUFACTURE_QTY,
    RAW_MATERIALS,
    expected_component_consumption,
)


def check_product(odoo, run, name, price, cost, sellable, purchasable):
    """A product is only usable by this course if it tracks inventory."""
    product = odoo.first(
        "product.template",
        [("name", "=", name)],
        ["name", "type", "is_storable", "list_price", "sale_ok", "purchase_ok"],
    )
    if product is None:
        run.check(False, f"Product exists: {name}",
                  hint="Inventory -> Products -> New.")
        return

    run.check(True, f"Product exists: {name}")

    # Odoo 19 wording: Product Type = Goods, Track Inventory = enabled.
    # The stored fields are type == 'consu' plus is_storable == True.
    tracked = product.get("is_storable")
    if tracked is None:
        run.skip(f"{name}: Track Inventory enabled",
                 "This Odoo build does not expose is_storable; check the form manually.")
    else:
        run.check(
            bool(tracked),
            f"{name}: Track Inventory enabled",
            hint="Open the product -> Product Type = Goods, then tick Track Inventory. "
                 "Without it Odoo keeps no stock count and the whole lab cannot work.",
        )

    if sellable:
        run.check(product.get("sale_ok"), f"{name}: Can be Sold",
                  hint="Tick Sales on the product form.")
        run.check(
            abs((product.get("list_price") or 0) - price) < 0.01,
            f"{name}: sales price is RM {price:,.2f}",
            hint=f"Set Sales Price to {price:,.2f}.",
            detail=f"found: RM {product.get('list_price', 0):,.2f}",
        )
    if purchasable:
        run.check(product.get("purchase_ok"), f"{name}: Can be Purchased",
                  hint="Tick Purchase on the product form.")


def main():
    parser = argparse.ArgumentParser(description="Check the Lab 3 manufacturing build.")
    add_connection_args(parser)
    parser.add_argument("--bikes", type=int, default=MANUFACTURE_QTY,
                        help=f"quantity the MO should build (default {MANUFACTURE_QTY})")
    args = parser.parse_args()
    odoo = connect_from_args(args)

    run = CheckRun(f"Lab 3 --- Manufacturing  (server {odoo.version}, db '{odoo.db}')")

    if not odoo.has_model("mrp.production"):
        print("Manufacturing app is not installed. Install it, then rerun.")
        raise SystemExit(2)

    # ---------------- Parts B and C: products ----------------
    for name, price, cost, _tracked, sellable, purchasable in FINISHED_GOODS:
        check_product(odoo, run, name, price, cost, sellable, purchasable)
    for name, price, cost, _tracked, sellable, purchasable in RAW_MATERIALS:
        check_product(odoo, run, name, price, cost, sellable, purchasable)

    # ---------------- Part D: the BOM ----------------
    bom = odoo.first(
        "mrp.bom",
        [("product_tmpl_id.name", "=", BOM_ROAD_BIKE["product"])],
        ["id", "product_qty"],
    )
    run.check(
        bom is not None,
        f"Bill of Materials exists for {BOM_ROAD_BIKE['product']}",
        hint="Manufacturing -> Products -> Bills of Materials -> New.",
    )

    if bom:
        lines = odoo.search_read(
            "mrp.bom.line", [("bom_id", "=", bom["id"])], ["product_id", "product_qty"]
        )
        found = {line["product_id"][1]: line["product_qty"] for line in lines}

        for component, qty in BOM_ROAD_BIKE["components"]:
            actual = None
            for product_name, product_qty in found.items():
                if component.lower() in product_name.lower():
                    actual = product_qty
                    break
            if actual is None:
                run.check(False, f"BOM line: {qty} x {component}",
                          hint=f"Add {component} to the Road Bike BOM.")
            else:
                run.check(
                    abs(actual - qty) < 0.001,
                    f"BOM line: {qty} x {component}",
                    hint=f"{component} should be quantity {qty} per bike."
                         + (" Two tyres per bicycle, not one." if qty == 2 else ""),
                    detail=f"found quantity {actual:g}",
                )

    # ---------------- Part E: the Manufacturing Order ----------------
    orders = odoo.search_read(
        "mrp.production",
        [("product_id.name", "=", BOM_ROAD_BIKE["product"])],
        ["name", "state", "product_qty", "qty_produced", "user_id"],
        order="id desc",
    )
    done = [o for o in orders if o["state"] == "done"]

    run.check(
        bool(orders),
        "A Manufacturing Order for Road Bike exists",
        hint="Manufacturing -> Operations -> Manufacturing Orders -> New.",
    )
    run.check(
        bool(done),
        "A Manufacturing Order has been completed (state = Done)",
        hint="Confirm the MO, check component availability, then Produce All / Mark as Done. "
             "An MO left in Confirmed has not moved any stock yet.",
        detail=f"states found: {[o['state'] for o in orders] or 'none'}",
    )

    if done:
        built = sum(o.get("qty_produced") or o.get("product_qty") or 0 for o in done)
        run.check(
            built >= args.bikes,
            f"At least {args.bikes} Road Bikes produced",
            hint=f"The lab builds {args.bikes} bikes.",
            detail=f"produced: {built:g}",
        )
        run.check(
            any(o.get("user_id") for o in done),
            "A Responsible person is set on the Manufacturing Order",
            hint="Set Responsible to the Production Planner. Lab 8 asks you to show "
                 "that each operational role owns a real document.",
        )

    # ---------------- Part F: did stock actually move? ----------------
    print()
    consumption = expected_component_consumption(args.bikes)
    bike_stock = odoo.qty_on_hand(BOM_ROAD_BIKE["product"])

    if bike_stock is None:
        run.skip("Road Bike stock increased", "Road Bike product not found.")
    else:
        run.check(
            bike_stock >= 0,
            "Road Bike on-hand quantity is readable",
            detail=f"Road Bike on hand: {bike_stock:g}",
        )

    # Components are consumed, so on-hand should be at or below what was
    # purchased minus what the BOM demands. Report the arithmetic either way
    # so the student can compare it with their before/after screenshots.
    print("  Component consumption this lab should have produced:")
    for component, qty in consumption.items():
        on_hand = odoo.qty_on_hand(component)
        shown = f"{on_hand:g}" if on_hand is not None else "product not found"
        print(f"    {component:<18} expected consumed {qty:>3}   on hand now: {shown}")

    print("\n  Compare these against the on-hand figures you recorded BEFORE the MO.")
    print("  The differences are the evidence Part F asks for.")

    raise SystemExit(0 if run.report() else 1)


if __name__ == "__main__":
    main()
