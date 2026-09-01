"""
Generate the CSV files students import into Odoo.

    py make_import_csvs.py

Typing six products, five employees and three vendors by hand wastes lab
time and produces a different database on every machine, which makes the
checkers useless. Odoo imports CSV natively:

    open the list view  ->  gear icon / Favorites  ->  Import records
    ->  Upload File  ->  check the column mapping  ->  Import

Every file is written from _shared/west_end_data.py, so the CSVs, the
checkers and the notes can never disagree about a price or a quantity.

Importing is a legitimate ERP skill in its own right --- data migration is
one of the implementation challenges Lab 2 asks you to discuss --- so pay
attention to what the mapping step is doing rather than clicking through it.
"""

import csv
import os

from west_end_data import (
    CUSTOMER,
    DEPARTMENT_MANAGERS,
    DEPARTMENTS,
    EMPLOYEES,
    FINISHED_GOODS,
    RAW_MATERIALS,
    VENDORS,
)

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


def write(lab_folder, filename, header, rows, note):
    folder = os.path.join(ROOT, lab_folder)
    os.makedirs(folder, exist_ok=True)
    path = os.path.join(folder, filename)
    with open(path, "w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(header)
        writer.writerows(rows)
    rel = os.path.join(lab_folder, filename)
    print(f"  wrote {rel:<44} {len(rows)} rows   {note}")
    return path


def main():
    print("Generating Odoo import files from west_end_data.py\n")

    # ---------------- Lab 1: departments ----------------
    write(
        "Lab01", "import_departments.csv",
        ["name", "manager_id/id"],
        # Managers are set afterwards in the UI: the employees do not exist
        # yet at the moment the departments are imported, and Odoo cannot
        # resolve a reference to a record that has not been created.
        [[d, ""] for d in DEPARTMENTS],
        "Employees > Departments > Import",
    )

    # ---------------- Lab 1: employees ----------------
    write(
        "Lab01", "import_employees.csv",
        ["name", "job_title", "department_id"],
        [[name, job, dept] for name, job, dept, _owns in EMPLOYEES],
        "Employees > Import (import departments first)",
    )

    # ---------------- Lab 3: products ----------------
    # Odoo 19: Product Type = Goods is stored as type 'consu', and
    # "Track Inventory" is the is_storable flag. Both are needed or the
    # course workflow keeps no stock at all.
    product_rows = []
    for name, price, cost, tracked, sellable, purchasable in FINISHED_GOODS + RAW_MATERIALS:
        product_rows.append([
            name, "consu", "TRUE" if tracked else "FALSE",
            f"{price:.2f}", f"{cost:.2f}",
            "TRUE" if sellable else "FALSE",
            "TRUE" if purchasable else "FALSE",
        ])
    write(
        "Lab03", "import_products.csv",
        ["name", "type", "is_storable", "list_price", "standard_price",
         "sale_ok", "purchase_ok"],
        product_rows,
        "Inventory > Products > Import",
    )

    # ---------------- Lab 4: customer ----------------
    write(
        "Lab04", "import_customer.csv",
        ["name", "is_company", "city", "country_id", "customer_rank"],
        [[CUSTOMER["name"], "TRUE", CUSTOMER["city"], CUSTOMER["country"], "1"]],
        "Contacts > Import",
    )

    # ---------------- Lab 7: vendors ----------------
    write(
        "Lab07", "import_vendors.csv",
        ["name", "is_company", "city", "country_id", "supplier_rank"],
        [[vendor, "TRUE", "Ipoh", "Malaysia", "1"] for vendor, _ in VENDORS],
        "Contacts > Import",
    )

    # The vendor-to-product link lives on product.supplierinfo. It is listed
    # here as a reference table rather than an import file: the link is
    # quicker to make on the product's Purchase tab, and doing it by hand is
    # what teaches you where the relationship actually lives.
    link_rows = []
    for vendor, supplies in VENDORS:
        for product in supplies:
            cost = next(
                (c for n, _p, c, *_ in RAW_MATERIALS if n == product), 0.0
            )
            link_rows.append([product, vendor, f"{cost:.2f}"])
    write(
        "Lab07", "vendor_product_links.csv",
        ["product", "vendor", "vendor_price"],
        link_rows,
        "reference only - set on each product's Purchase tab",
    )

    print("\nImport order matters. Departments before employees, products before")
    print("the BOM, vendors before the vendor-product links. Odoo cannot resolve")
    print("a reference to a record that does not exist yet.")


if __name__ == "__main__":
    main()
