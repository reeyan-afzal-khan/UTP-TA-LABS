"""
Lab 2 Part C --- which app owns which record, and what feeds what.

    py show_modularity.py --password YOUR_ADMIN_PASSWORD

The lab asks you to open the app grid and work out which app owns the
customer, opportunity, quotation, purchase order, receipt, BOM,
manufacturing order, delivery, invoice and employee, then draw the arrows
between them.

This prints the same map from the live database, with a live record count
beside each row, so your diagram can be checked rather than guessed. It
changes nothing.

The point is modularity WITHOUT silos: the records sit in different apps
because the workflows differ, yet they stay connected through shared master
data and document links. The 'fed by' column is where you should be looking.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "_shared"))

from odoo_client import add_connection_args, connect_from_args  # noqa: E402

# record label, model, owning app, what creates it
RECORD_MAP = [
    ("Customer / Vendor",  "res.partner",     "Contacts",      "created by hand; shared by every other app"),
    ("Employee",           "hr.employee",     "Employees",     "created by hand; supplies the people who own documents"),
    ("Opportunity",        "crm.lead",        "CRM",           "created by hand from a lead"),
    ("Quotation",          "sale.order",      "Sales",         "the opportunity's New Quotation action"),
    ("Sales Order",        "sale.order",      "Sales",         "confirming the quotation (same record, new state)"),
    ("Delivery",           "stock.picking",   "Inventory",     "confirming the Sales Order"),
    ("Customer Invoice",   "account.move",    "Invoicing",     "Create Invoice on the Sales Order"),
    ("Payment",            "account.payment", "Invoicing",     "Register Payment on the posted invoice"),
    ("Purchase Order",     "purchase.order",  "Purchase",      "confirming an RFQ"),
    ("Receipt",            "stock.picking",   "Inventory",     "confirming the Purchase Order"),
    ("Bill of Materials",  "mrp.bom",         "Manufacturing", "created by hand from products"),
    ("Manufacturing Order","mrp.production",  "Manufacturing", "created by hand; consumes the BOM"),
]

# the arrows the lab asks students to draw
FLOWS = [
    ("Opportunity",     "Quotation",         "customer, salesperson and expected value carry over"),
    ("Quotation",       "Sales Order",       "confirmation; the commercial commitment is made"),
    ("Sales Order",     "Delivery",          "fulfilment demand reaches Inventory"),
    ("Sales Order",     "Customer Invoice",  "billing data is reused, not retyped"),
    ("Customer Invoice","Payment",           "settlement closes the loop back to Sales"),
    ("Purchase Order",  "Receipt",           "goods arrive and stock rises"),
    ("Receipt",         "Manufacturing Order","components become available to consume"),
    ("Bill of Materials","Manufacturing Order","the recipe decides what is consumed"),
    ("Manufacturing Order","Delivery",       "finished bikes become available to ship"),
]


def main():
    parser = argparse.ArgumentParser(description="Print the Lab 2 modularity map.")
    add_connection_args(parser)
    args = parser.parse_args()
    odoo = connect_from_args(args)

    width = 96
    print("=" * width)
    print(f"Lab 2 Part C --- record ownership map  (db '{odoo.db}')")
    print("=" * width)
    print(f"  {'Record':<21}{'Odoo model':<19}{'App':<15}{'count':>7}   created by")
    print("-" * width)

    for label, model, app, created_by in RECORD_MAP:
        if not odoo.has_model(model):
            count = "n/a"
        else:
            try:
                count = str(odoo.count(model, []))
            except Exception:
                count = "?"
        print(f"  {label:<21}{model:<19}{app:<15}{count:>7}   {created_by}")

    print()
    print("=" * width)
    print("The arrows to draw")
    print("=" * width)
    for source, target, why in FLOWS:
        print(f"  {source:<22} -> {target:<22} {why}")

    print()
    print("  Notice two things your diagram should show:")
    print()
    print("  1. Quotation and Sales Order are the SAME record (sale.order) in two")
    print("     states. Integration is not always a new document --- often it is a")
    print("     state change that unlocks the next step.")
    print()
    print("  2. Delivery and Receipt are also the same model (stock.picking).")
    print("     Inventory does not care whether goods are arriving or leaving; it")
    print("     records a movement either way. That is modularity done well: one")
    print("     mechanism, reused, instead of two half-duplicated ones.")


if __name__ == "__main__":
    main()
