"""
Lab 7 checker --- vendors, purchase orders, and receipts.

    py check_supply_chain.py --password YOUR_ADMIN_PASSWORD

Part D of the lab asks students to say why a Receipt is not the same as a
Purchase Order. This checker enforces the distinction: a confirmed PO earns
one tick, and only a validated Receipt earns the tick that says stock exists.
Manufacturing cannot start until the second one passes.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_shared"))

from odoo_client import CheckRun, add_connection_args, connect_from_args  # noqa: E402
from west_end_data import PURCHASE_QUANTITIES, RAW_MATERIALS, VENDORS  # noqa: E402


def main():
    parser = argparse.ArgumentParser(description="Check the Lab 7 supply chain build.")
    add_connection_args(parser)
    args = parser.parse_args()
    odoo = connect_from_args(args)

    run = CheckRun(f"Lab 7 --- Supply chain  (server {odoo.version}, db '{odoo.db}')")

    if not odoo.has_model("purchase.order"):
        print("Purchase app is not installed. Install it, then rerun.")
        raise SystemExit(2)

    # ---------------- Part A: vendors ----------------
    for vendor_name, supplies in VENDORS:
        vendor = odoo.first(
            "res.partner", [("name", "=", vendor_name)], ["id", "name"]
        )
        run.check(
            vendor is not None,
            f"Vendor exists: {vendor_name}",
            hint=f"Contacts -> New -> Company. Supplies: {', '.join(supplies)}.",
        )

    # ---------------- Part A: vendor-product links ----------------
    # A vendor record that is not linked to a product will not appear when
    # you try to buy that product --- the most common Lab 7 dead end.
    if odoo.has_model("product.supplierinfo"):
        links = odoo.search_read(
            "product.supplierinfo", [], ["partner_id", "product_tmpl_id", "price"]
        )
        linked_pairs = set()
        for link in links:
            partner = link.get("partner_id")
            template = link.get("product_tmpl_id")
            if partner and template:
                linked_pairs.add((partner[1], template[1]))

        for vendor_name, supplies in VENDORS:
            for product in supplies:
                found = any(
                    vendor_name.lower() in v.lower() and product.lower() in p.lower()
                    for v, p in linked_pairs
                )
                run.check(
                    found,
                    f"Vendor link: {vendor_name} -> {product}",
                    hint=f"Open {product} -> Purchase tab -> add {vendor_name} with a price.",
                )
    else:
        run.skip("Vendor-product links", "product.supplierinfo not available.")

    # ---------------- Part B: purchase orders ----------------
    orders = odoo.search_read(
        "purchase.order", [], ["id", "name", "state", "partner_id", "amount_total", "user_id"],
        order="id desc",
    )
    confirmed = [o for o in orders if o["state"] in ("purchase", "done")]
    drafts = [o for o in orders if o["state"] in ("draft", "sent")]

    run.check(
        bool(orders),
        "At least one RFQ or Purchase Order exists",
        hint="Purchase -> New. One RFQ per vendor.",
    )
    run.check(
        bool(confirmed),
        "At least one RFQ has been confirmed into a Purchase Order",
        hint="Open the RFQ and press Confirm Order. An RFQ is a request; only a "
             "confirmed PO is a commitment, and only a PO creates a Receipt.",
        detail=f"{len(confirmed)} confirmed, {len(drafts)} still draft/RFQ",
    )
    if confirmed:
        run.check(
            any(o.get("user_id") for o in confirmed),
            "A Buyer owns the Purchase Order",
            hint="Set Buyer to the Purchasing Officer.",
        )

    # ---------------- Part C: receipts ----------------
    receipts = odoo.search_read(
        "stock.picking",
        [("picking_type_id.code", "=", "incoming")]
        if odoo.has_model("stock.picking.type") else [],
        ["id", "name", "state", "origin"],
        order="id desc",
    ) if odoo.has_model("stock.picking") else []

    validated = [r for r in receipts if r["state"] == "done"]

    run.check(
        bool(receipts),
        "A Receipt was created from a Purchase Order",
        hint="Confirming a PO creates it. Use the Receipt smart button.",
    )
    run.check(
        bool(validated),
        "At least one Receipt has been validated (state = Done)",
        hint="Open the Receipt and press Validate. THIS is the event that puts stock "
             "on hand. Until it happens, Manufacturing has nothing to consume.",
        detail=f"states found: {[r['state'] for r in receipts] or 'none'}",
    )

    # ---------------- did the stock actually arrive? ----------------
    print()
    print("  Component stock after receipts (Part C evidence):")
    any_stock = False
    for name, *_ in RAW_MATERIALS:
        on_hand = odoo.qty_on_hand(name)
        planned = PURCHASE_QUANTITIES.get(name, 0)
        if on_hand is None:
            print(f"    {name:<18} product not found")
            continue
        if on_hand > 0:
            any_stock = True
        print(f"    {name:<18} planned purchase {planned:>3}   on hand now: {on_hand:g}")

    run.check(
        any_stock or bool(validated),
        "Purchased components are on hand (or a receipt is validated)",
        hint="If every component reads 0 and no receipt is Done, the goods were ordered "
             "but never received. That is exactly the Part D distinction.",
    )

    print()
    print("  Part D, in one line each:")
    print("    Purchase Order  proves a commitment to buy.")
    print("    Receipt         proves the goods physically arrived.")
    print("    The Receipt is what makes components usable by Manufacturing.")
    print("    Supplier on-time and fill-rate metrics compare the RECEIPT against")
    print("    the promised date and the ordered quantity --- not the order itself.")

    raise SystemExit(0 if run.report() else 1)


if __name__ == "__main__":
    main()
