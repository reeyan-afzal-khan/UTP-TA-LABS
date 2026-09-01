"""
Lab 5 checker --- the order-to-cash chain, link by link.

    py check_order_to_cash.py --password YOUR_ADMIN_PASSWORD

This is the lab where ERP integration is supposed to become visible, so the
checker follows the LINKS rather than looking at each document alone:

    opportunity -> quotation -> Sales Order -> Delivery -> Invoice -> Payment

At each step it asks the question the notes ask: was the information reused,
or retyped? A price on the invoice that differs from the Sales Order means
the integration argument has failed, and that is reported as a failure even
though both documents look perfectly valid on their own.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_shared"))

from odoo_client import CheckRun, add_connection_args, connect_from_args  # noqa: E402
from west_end_data import CUSTOMER, SALES_ORDER  # noqa: E402


def main():
    parser = argparse.ArgumentParser(description="Check the Lab 5 order-to-cash flow.")
    add_connection_args(parser)
    args = parser.parse_args()
    odoo = connect_from_args(args)

    run = CheckRun(f"Lab 5 --- Order to cash  (server {odoo.version}, db '{odoo.db}')")

    # ---------------- the customer ----------------
    customer = odoo.first(
        "res.partner", [("name", "=", CUSTOMER["name"])], ["id", "name", "is_company"]
    )
    run.check(
        customer is not None,
        f"Customer exists: {CUSTOMER['name']}",
        hint="Contacts -> New -> Company.",
    )
    if customer is None:
        raise SystemExit(0 if run.report() else 1)

    # ---------------- Part A: the Sales Order ----------------
    orders = odoo.search_read(
        "sale.order",
        [("partner_id", "=", customer["id"])],
        ["id", "name", "state", "amount_total", "invoice_status", "user_id"],
        order="id desc",
    )
    confirmed = [o for o in orders if o["state"] in ("sale", "done")]

    run.check(bool(orders), "A quotation exists for the customer",
              hint="Sales -> Quotations -> New, or use the CRM opportunity's quotation action.")
    run.check(
        bool(confirmed),
        "The quotation has been confirmed into a Sales Order",
        hint="Open the quotation and press Confirm. Until then no Delivery or Invoice exists.",
        detail=f"states found: {[o['state'] for o in orders] or 'none'}",
    )
    if not confirmed:
        raise SystemExit(0 if run.report() else 1)

    order = confirmed[0]
    run.check(
        abs(order["amount_total"] - SALES_ORDER["total"]) < 0.01,
        f"Sales Order total is RM {SALES_ORDER['total']:,.2f}",
        hint=f"{SALES_ORDER['quantity']} x {SALES_ORDER['product']} "
             f"@ RM {SALES_ORDER['unit_price']:,.2f}.",
        detail=f"found: RM {order['amount_total']:,.2f}",
    )
    run.check(
        bool(order.get("user_id")),
        "A Salesperson owns the Sales Order",
        hint="Set Salesperson to the Sales Manager.",
    )

    # order line, used later to compare against the invoice line
    lines = odoo.search_read(
        "sale.order.line",
        [("order_id", "=", order["id"])],
        ["product_id", "product_uom_qty", "price_unit"],
    )
    order_line = lines[0] if lines else None
    if order_line:
        run.check(
            abs(order_line["product_uom_qty"] - SALES_ORDER["quantity"]) < 0.001,
            f"Sales Order is for {SALES_ORDER['quantity']} units",
            detail=f"found: {order_line['product_uom_qty']:g}",
            hint=f"The lab orders {SALES_ORDER['quantity']} bikes.",
        )

    # ---------------- Part B: the Delivery ----------------
    pickings = odoo.search_read(
        "stock.picking",
        [("sale_id", "=", order["id"])],
        ["name", "state", "date_done"],
    )
    delivered = [p for p in pickings if p["state"] == "done"]

    run.check(
        bool(pickings),
        "A Delivery was created from the Sales Order",
        hint="Confirming the order should create it. Check the Delivery smart button.",
    )
    run.check(
        bool(delivered),
        "The Delivery has been validated (state = Done)",
        hint="Open the Delivery -> Check Availability -> Validate. If the bikes cannot be "
             "reserved, the Manufacturing Order in Lab 3 is not Done yet.",
        detail=f"states found: {[p['state'] for p in pickings] or 'none'}",
    )

    # ---------------- Part C: the Invoice ----------------
    invoices = odoo.search_read(
        "account.move",
        [("partner_id", "=", customer["id"]), ("move_type", "=", "out_invoice")],
        ["id", "name", "state", "amount_total", "amount_residual", "payment_state"],
        order="id desc",
    )
    posted = [i for i in invoices if i["state"] == "posted"]

    run.check(bool(invoices), "A customer invoice exists",
              hint="From the Sales Order press Create Invoice.")
    run.check(
        bool(posted),
        "The invoice has been posted (no longer Draft)",
        hint="Open the invoice and press Confirm/Post. Register Payment is unavailable "
             "while the invoice is Draft.",
        detail=f"states found: {[i['state'] for i in invoices] or 'none'}",
    )

    if posted:
        invoice = posted[0]

        # THE integration check. Both documents can be individually valid and
        # still disagree --- which is exactly the Fitter Snacker failure.
        run.check(
            abs(invoice["amount_total"] - order["amount_total"]) < 0.01,
            "Invoice total matches the Sales Order total",
            hint="If these differ, the price was re-entered instead of carried forward. "
                 "That is the integration failure Chapter 3 describes.",
            detail=f"order RM {order['amount_total']:,.2f} vs "
                   f"invoice RM {invoice['amount_total']:,.2f}",
        )

        invoice_lines = odoo.search_read(
            "account.move.line",
            [("move_id", "=", invoice["id"]), ("display_type", "=", "product")],
            ["product_id", "quantity", "price_unit"],
        )
        if order_line and invoice_lines:
            same_product = (
                invoice_lines[0].get("product_id") and order_line.get("product_id")
                and invoice_lines[0]["product_id"][0] == order_line["product_id"][0]
            )
            run.check(
                same_product,
                "Invoice bills the same product as the order",
                hint="The invoice line should have been generated from the order line.",
            )
            run.check(
                abs(invoice_lines[0]["quantity"] - order_line["product_uom_qty"]) < 0.001,
                "Invoice quantity matches the ordered quantity",
                detail=f"ordered {order_line['product_uom_qty']:g}, "
                       f"invoiced {invoice_lines[0]['quantity']:g}",
                hint="Billing a different quantity from the one shipped is the classic "
                     "unintegrated-process error.",
            )

        # ---------------- Part D: the Payment ----------------
        paid = invoice.get("payment_state") in ("paid", "in_payment", "reversed")
        run.check(
            paid,
            "Payment has been registered against the invoice",
            hint="Open the posted invoice -> Register Payment -> Bank or Cash, full amount.",
            detail=f"payment_state: {invoice.get('payment_state')}, "
                   f"outstanding RM {invoice.get('amount_residual', 0):,.2f}",
        )

    # ---------------- the whole chain ----------------
    print()
    print("  The chain this lab is really about:")
    print(f"    customer   {CUSTOMER['name']}")
    print(f"    order      {order['name']}  RM {order['amount_total']:,.2f}")
    print(f"    delivery   {delivered[0]['name'] if delivered else '(not validated)'}")
    print(f"    invoice    {posted[0]['name'] if posted else '(not posted)'}")
    print("  Every link reuses the one before it. Nothing is retyped.")

    raise SystemExit(0 if run.report() else 1)


if __name__ == "__main__":
    main()
