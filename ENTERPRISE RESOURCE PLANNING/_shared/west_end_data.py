"""
West End Bicycles --- the canonical master data for every ERP lab.

Every lab script, CSV, and checker reads its values from here, so the Road
Bike price appears in exactly one place. If your tutor changes a figure,
change it once in this file and every lab agrees again.

The values come from the supplied Odoo 19 Community build guide and the
capstone data set in the notes.
"""

COMPANY = {
    "name": "West End Bicycles",
    "city": "Ipoh",
    "state": "Perak",
    "country": "Malaysia",
    "currency": "MYR",
}

# ---------------------------------------------------------------- Lab 1
DEPARTMENTS = [
    "Sales and Marketing",
    "Accounting and Finance",
    "Supply Chain",
    "Human Resources",
]

# Each operational role must appear as an OWNER on a real transaction later.
# That link is the point of Lab 8 Part F: an employee who never owns a
# document is decoration, not organisation data.
EMPLOYEES = [
    # name,               job title,            department,              owns
    ("Aisyah Rahman",     "Sales Manager",       "Sales and Marketing",   "Salesperson on the opportunity, quotation and Sales Order"),
    ("Daniel Lim",        "Purchasing Officer",  "Supply Chain",          "Buyer on every RFQ and Purchase Order"),
    ("Kavitha Nair",      "Production Planner",  "Supply Chain",          "Responsible on the Manufacturing Order"),
    ("Faizal Osman",      "Accountant",          "Accounting and Finance","Owns the invoice and payment"),
    ("Mei Ling Tan",      "HR Officer",          "Human Resources",       "Owns employee and department records"),
]

DEPARTMENT_MANAGERS = {
    "Sales and Marketing":    "Aisyah Rahman",
    "Accounting and Finance": "Faizal Osman",
    "Supply Chain":           "Daniel Lim",
    "Human Resources":        "Mei Ling Tan",
}

REQUIRED_APPS = [
    ("contacts",      "Contacts",      "Shared customer and vendor records"),
    ("crm",           "CRM",           "Opportunities and pipeline"),
    ("hr",            "Employees",     "Departments, people, managers"),
    ("stock",         "Inventory",     "Receipts, deliveries, on-hand stock"),
    ("account",       "Invoicing",     "Customer invoices and payments"),
    ("mrp",           "Manufacturing", "BOMs and Manufacturing Orders"),
    ("purchase",      "Purchase",      "RFQs, Purchase Orders, vendor receipts"),
    ("sale_management", "Sales",       "Quotations and Sales Orders"),
]

# ---------------------------------------------------------------- Lab 3
# Odoo 19: "Storable Product" is gone. Physical stock items are
# Product Type = Goods  AND  Track Inventory = enabled.
FINISHED_GOODS = [
    # name,       sales price, cost, tracked, can_sell, can_buy
    ("Road Bike",  1000.00,    650.00, True,   True,     False),
]

RAW_MATERIALS = [
    ("Aluminium Frame", 0.0, 250.00, True, False, True),
    ("Rubber Tires",    0.0,  45.00, True, False, True),
    ("Brake Set",       0.0,  80.00, True, False, True),
    ("Gear Set",        0.0, 120.00, True, False, True),
    ("Bicycle Chain",   0.0,  35.00, True, False, True),
]

# One Road Bike consumes exactly this. Note the 2 tyres --- the only
# component whose quantity is not 1, and therefore the one that proves a
# student read the BOM rather than assuming.
BOM_ROAD_BIKE = {
    "product": "Road Bike",
    "quantity": 1,
    "components": [
        ("Aluminium Frame", 1),
        ("Rubber Tires",    2),
        ("Brake Set",       1),
        ("Gear Set",        1),
        ("Bicycle Chain",   1),
    ],
}

# ---------------------------------------------------------------- Lab 7
VENDORS = [
    ("Ipoh Metal Supply",     ["Aluminium Frame"]),
    ("RubberWheel Co.",       ["Rubber Tires"]),
    ("BikeParts Supplier",    ["Brake Set", "Gear Set", "Bicycle Chain"]),
]

# Enough to build 5 bikes, with the tyre quantity doubled as the BOM demands.
MANUFACTURE_QTY = 5
PURCHASE_QUANTITIES = {
    "Aluminium Frame": 5,
    "Rubber Tires":    10,
    "Brake Set":       5,
    "Gear Set":        5,
    "Bicycle Chain":   5,
}

# ---------------------------------------------------------------- Labs 4-5
CUSTOMER = {
    "name": "Seri Iskandar Cycling Club",
    "city": "Seri Iskandar",
    "state": "Perak",
    "country": "Malaysia",
    "is_company": True,
}

OPPORTUNITY = {
    "name": "Road Bike Order - Seri Iskandar Cycling Club",
    "expected_revenue": 5000.00,
    "salesperson": "Aisyah Rahman",
    "note": "Customer requested 5 Road Bikes.",
}

SALES_ORDER = {
    "customer": "Seri Iskandar Cycling Club",
    "product": "Road Bike",
    "quantity": 5,
    "unit_price": 1000.00,
    "total": 5000.00,
}


def expected_component_consumption(bikes=MANUFACTURE_QTY):
    """How much of each component an MO for `bikes` units must consume.

    Lab 3 Part F asks students to verify this against real stock movements,
    so the arithmetic lives here rather than being retyped per lab.
    """
    return {name: qty * bikes for name, qty in BOM_ROAD_BIKE["components"]}


def stock_after_full_cycle(bikes=MANUFACTURE_QTY):
    """On-hand quantities once the whole 21-step story has run.

    purchase -> receive -> manufacture -> deliver
    Components are bought exactly to plan, so every one ends at zero, and
    the bikes built are the bikes delivered, so Road Bike also ends at zero.
    A non-zero balance means a step was skipped or a quantity was mistyped.
    """
    consumed = expected_component_consumption(bikes)
    stock = {name: PURCHASE_QUANTITIES[name] - consumed[name] for name in consumed}
    stock["Road Bike"] = bikes - SALES_ORDER["quantity"]
    return stock


if __name__ == "__main__":
    print("West End Bicycles master data\n")
    print(f"Company : {COMPANY['name']}, {COMPANY['city']}, {COMPANY['country']}")
    print(f"Bikes to manufacture : {MANUFACTURE_QTY}")
    print(f"Customer order       : {SALES_ORDER['quantity']} x "
          f"{SALES_ORDER['product']} @ RM {SALES_ORDER['unit_price']:,.2f} "
          f"= RM {SALES_ORDER['total']:,.2f}")

    print("\nComponents consumed by the Manufacturing Order:")
    for name, qty in expected_component_consumption().items():
        bought = PURCHASE_QUANTITIES[name]
        print(f"  {name:<18} bought {bought:>3}   consumed {qty:>3}   left {bought - qty:>3}")

    print("\nOn-hand stock once the full cycle is complete:")
    for name, qty in stock_after_full_cycle().items():
        print(f"  {name:<18} {qty}")
    print("\nEverything lands on zero: bought to plan, built to plan, sold to plan.")
