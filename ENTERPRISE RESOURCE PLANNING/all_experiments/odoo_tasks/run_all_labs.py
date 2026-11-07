"""Run every Odoo task in the eight practicals and the capstone, on one database.

Run inside an Odoo shell, from the course folder, through the launcher's run command:

    sh tools/mac/odoo.sh run all_experiments/odoo_tasks/run_all_labs.py

On Linux, use sh tools/linux/odoo.sh instead. On Windows, use the odoo launcher in the
windows folder under tools, which takes the same run command.

The labs follow the tutorial order, but their records depend on each other, so
this script follows the capstone's order instead: Lab 1, Lab 7, Lab 3, Lab 4,
Lab 5, then the labs that inspect those records (2, 6, 8). The two exercises the
labs ask for "in a separate record" (a partial receipt and a component shortage)
run last, so they do not disturb the capstone's stock figures.

Documents are created and moved on as the role that owns them, with with_user(),
so a role without the right access fails here as it would in the browser.

Values the book states are used as printed. The supplied guide is not in the
course folder, so what it alone would give is marked ASSUMED below.
Each check is written to data/results/evidence.json, in your system's folder under tools.
"""
import json
import os
import time
from pathlib import Path

from psycopg2.errors import SerializationFailure

RESULTS = Path(os.environ["ODOO_LAB_RESULTS"])
LAB_PASSWORD = Path(os.environ["ODOO_LAB_LOGIN_FILE"]).read_text().strip()

env = env(user=env.ref("base.user_admin").id)  # noqa: F821 (provided by the shell)
company = env.company
evidence = {}
failures = []


def note(lab, key, value):
    evidence.setdefault(lab, {"checks": [], "records": {}})["records"][key] = value


def check(lab, what, actual, expected):
    ok = actual == expected
    evidence.setdefault(lab, {"checks": [], "records": {}})["checks"].append(
        {"check": what, "actual": actual, "expected": expected, "ok": ok})
    print(f"  [{'PASS' if ok else 'FAIL'}] {what}: {actual!r}" + ("" if ok else f" (expected {expected!r})"))
    if not ok:
        failures.append(f"{lab}: {what}")


def stage(title):
    env.cr.commit()
    print(f"\n=== {title}", flush=True)


def on_hand(product):
    product.invalidate_recordset(["qty_available"])
    return product.with_context(warehouse_id=False).qty_available


def stock_table(items):
    return {name: on_hand(prod) for name, prod in items.items()}


def retrying(step):
    """Run one stock step, and repeat it if another transaction got there first.

    Odoo's web server does this for every request, but a shell script must do it
    itself. Conflicts are real here: an Odoo service on port 8069 runs scheduled
    jobs on every database on the server, including this one.
    """
    for attempt in range(6):
        env.cr.commit()
        try:
            result = step()
            env.cr.commit()
            return result
        except SerializationFailure:
            env.cr.rollback()
            if attempt == 5:
                raise
            print("  (write conflict with another Odoo process; retrying)", flush=True)
            time.sleep(attempt + 1)


def receive(picking, quantities=None):
    """Enter what physically arrived, then Validate (the Receipt screen)."""
    def step():
        for move in picking.move_ids:
            move.quantity = quantities[move.product_id.id] if quantities else move.product_uom_qty
            move.picked = True
        result = picking.with_context(skip_backorder=True).button_validate()
        assert result is True, f"Validate opened a dialog: {result}"
    retrying(step)


def buy(buyer, vendor, lines):
    """Raise an RFQ, confirm it into a Purchase Order, and return the order."""
    order = env["purchase.order"].with_user(buyer).create({
        "partner_id": vendor.id,
        "user_id": buyer.id,
        "order_line": [(0, 0, {"product_id": p.id, "product_qty": q}) for p, q in lines],
    })
    order.button_confirm()
    return order


def make(planner, bike, bom, qty):
    def step():
        order = env["mrp.production"].with_user(planner).create({
            "product_id": bike.id, "product_qty": qty, "bom_id": bom.id, "user_id": planner.id,
        })
        order.action_confirm()
        order.action_assign()
        return order
    return retrying(step)


def finish(order):
    def step():
        order.qty_producing = order.product_qty
        order._set_qty_producing()
        order.move_raw_ids.picked = True
        result = order.button_mark_done()
        assert order.state == "done", f"MO state is {order.state}: {result}"
    retrying(step)


# ---------------------------------------------------------------- Lab 1
stage("Lab 1: company, departments, employees, users")
malaysia = env.ref("base.my")
perak = env["res.country.state"].search([("country_id", "=", malaysia.id), ("name", "=", "Perak")], limit=1)
company.write({"name": "West End Bicycles", "city": "Ipoh", "state_id": perak.id, "country_id": malaysia.id})
check("lab01", "company", [company.name, company.city, company.state_id.name, company.country_id.name],
      ["West End Bicycles", "Ipoh", "Perak", "Malaysia"])
check("lab01", "company currency", company.currency_id.name, "MYR")
check("lab01", "version is Odoo 19 Community", [odoo.release.series, odoo.release.version_info[5]], ["19.0", ""])  # noqa: F821

apps = {"Contacts": "contacts", "CRM": "crm", "Employees": "hr", "Inventory": "stock",
        "Invoicing": "account", "Manufacturing": "mrp", "Purchase": "purchase", "Sales": "sale_management"}
installed = env["ir.module.module"].search([("name", "in", list(apps.values())), ("state", "=", "installed")]).mapped("name")
check("lab01", "eight course apps installed", sorted(installed), sorted(apps.values()))
check("lab01", "Accounting chart is Malaysian", env["ir.module.module"].search([("name", "=", "l10n_my")]).state, "installed")

# ASSUMED: the guide's staff names are not available, so employees carry their
# role as their name, and the department heads below are this script's choice.
departments = {name: env["hr.department"].create({"name": name}) for name in
               ["Sales and Marketing", "Accounting and Finance", "Supply Chain", "Human Resources"]}
ROLES = {
    "Sales Manager": ("Sales and Marketing", "sales.manager",
                      ["sales_team.group_sale_manager"]),
    "Purchasing Officer": ("Supply Chain", "purchasing.officer",
                           ["purchase.group_purchase_manager", "stock.group_stock_user"]),
    "Production Planner": ("Supply Chain", "production.planner",
                           ["mrp.group_mrp_manager", "stock.group_stock_user"]),
    "Accountant": ("Accounting and Finance", "accountant",
                   ["account.group_account_invoice"]),
    "HR Officer": ("Human Resources", "hr.officer",
                   ["hr.group_hr_user"]),
}
HEADS = {"Sales and Marketing": "Sales Manager", "Accounting and Finance": "Accountant",
         "Supply Chain": "Purchasing Officer", "Human Resources": "HR Officer"}

users, employees = {}, {}
Users = env["res.users"].with_context(no_reset_password=True)
for role, (dept, login, groups) in ROLES.items():
    users[role] = Users.create({
        "name": role, "login": login, "password": LAB_PASSWORD,
        "email": f"{login}@westend.example",
        "group_ids": [(6, 0, [env.ref("base.group_user").id] + [env.ref(g).id for g in groups])],
    })
    employees[role] = env["hr.employee"].create({
        "name": role, "job_title": role, "department_id": departments[dept].id,
        "user_id": users[role].id, "work_email": f"{login}@westend.example",
    })
for dept, head in HEADS.items():
    departments[dept].manager_id = employees[head]
employees["Production Planner"].parent_id = employees["Purchasing Officer"]
stage("Lab 1: checks")
for dept, head in HEADS.items():
    check("lab01", f"head of {dept}", departments[dept].manager_id.name, head)
for role, (dept, login, _) in ROLES.items():
    check("lab01", f"{role} links employee, department and login",
          [employees[role].department_id.name, employees[role].user_id.login], [dept, login])
check("lab01", "org chart module installed", env["ir.module.module"].search([("name", "=", "hr_org_chart")]).state, "installed")

# Access: each role can reach its own work and is refused someone else's.
SM, BUYER, PLANNER, ACCT, HR = (users[r] for r in
                                ["Sales Manager", "Purchasing Officer", "Production Planner", "Accountant", "HR Officer"])
access = {
    "Sales Manager can create quotations": SM.has_group("sales_team.group_sale_salesman"),
    "Purchasing Officer can create POs": BUYER.has_group("purchase.group_purchase_user"),
    "Production Planner can run MOs": PLANNER.has_group("mrp.group_mrp_user"),
    "Accountant can post invoices": ACCT.has_group("account.group_account_invoice"),
    "HR Officer can manage employees": HR.has_group("hr.group_hr_user"),
    "Sales Manager cannot run MOs": not SM.has_group("mrp.group_mrp_user"),
    "HR Officer cannot create POs": not HR.has_group("purchase.group_purchase_user"),
}
for what, value in access.items():
    check("lab01", what, value, True)

# ---------------------------------------------------------------- Lab 3 B-C, Lab 7 A
stage("Lab 3 B-C: products. Lab 7 A: vendors and vendor links")
Template = env["product.template"]
bike_t = Template.create({"name": "Road Bike", "type": "consu", "is_storable": True,
                          "sale_ok": True, "purchase_ok": False, "list_price": 1000})
COSTS = {"Aluminium Frame": 200, "Rubber Tires": 40, "Brake Set": 70, "Gear Set": 90, "Bicycle Chain": 30}
parts_t = {name: Template.create({"name": name, "type": "consu", "is_storable": True, "sale_ok": False,
                                  "purchase_ok": True, "standard_price": cost})
           for name, cost in COSTS.items()}
bike = bike_t.product_variant_id
parts = {n: t.product_variant_id for n, t in parts_t.items()}
check("lab03", "Road Bike is Goods with Track Inventory, RM 1,000",
      [bike_t.type, bike_t.is_storable, bike_t.sale_ok, bike_t.list_price], ["consu", True, True, 1000.0])
for name, tmpl in parts_t.items():
    check("lab03", f"{name} is tracked and purchasable", [tmpl.type, tmpl.is_storable, tmpl.purchase_ok], ["consu", True, True])
note("lab03", "default_sales_tax_on_Road_Bike", bike_t.taxes_id.mapped("name"))

VENDORS = {"Ipoh Metal Supply": ["Aluminium Frame"], "RubberWheel Co.": ["Rubber Tires"],
           "BikeParts Supplier": ["Brake Set", "Gear Set", "Bicycle Chain"]}
vendors = {}
for vendor, supplied in VENDORS.items():
    vendors[vendor] = env["res.partner"].create({"name": vendor, "is_company": True, "supplier_rank": 1, "country_id": malaysia.id})
    for name in supplied:
        env["product.supplierinfo"].create({"partner_id": vendors[vendor].id, "product_tmpl_id": parts_t[name].id,
                                            "price": COSTS[name]})
for vendor, supplied in VENDORS.items():
    for name in supplied:
        check("lab07", f"{name} links to {vendor} at guide price",
              [parts_t[name].seller_ids.partner_id.name, parts_t[name].seller_ids.price], [vendor, float(COSTS[name])])
note("lab07", "lead_time_field_present", "delay" in env["product.supplierinfo"]._fields)

# ---------------------------------------------------------------- Lab 7 B-C
stage("Lab 7 B-C: RFQs, Purchase Orders, Receipts")
QTY = {"Aluminium Frame": 5, "Rubber Tires": 10, "Brake Set": 5, "Gear Set": 5, "Bicycle Chain": 5}
frame = parts["Aluminium Frame"]
before_any = on_hand(frame)
orders = {}
for vendor, supplied in VENDORS.items():
    orders[vendor] = buy(BUYER, vendors[vendor], [(parts[n], QTY[n]) for n in supplied])
check("lab07", "a confirmed PO alone adds no stock", on_hand(frame), before_any)
for vendor, order in orders.items():
    check("lab07", f"{vendor} RFQ became a PO, Buyer is the Purchasing Officer, Receipt linked",
          [order.state, order.user_id.name, len(order.picking_ids)], ["purchase", "Purchasing Officer", 1])
    receive(order.picking_ids.with_user(BUYER))
    check("lab07", f"{vendor} Receipt is Done", order.picking_ids.state, "done")
check("lab07", "frame on hand before and after receipt", [before_any, on_hand(frame)], [0.0, 5.0])
note("lab07", "purchase_orders", {v: {"po": o.name, "receipt": o.picking_ids.name,
                                      "untaxed": o.amount_untaxed, "total": o.amount_total}
                                  for v, o in orders.items()})

# ---------------------------------------------------------------- Lab 3 D-F
stage("Lab 3 D-F: BOM, Manufacturing Order, stock change")
BOM_LINES = {"Aluminium Frame": 1, "Rubber Tires": 2, "Brake Set": 1, "Gear Set": 1, "Bicycle Chain": 1}
bom = env["mrp.bom"].with_user(PLANNER).create({
    "product_tmpl_id": bike_t.id, "product_qty": 1,
    "bom_line_ids": [(0, 0, {"product_id": parts[n].id, "product_qty": q}) for n, q in BOM_LINES.items()],
})
check("lab03", "BOM lists all five components", {l.product_id.name: l.product_qty for l in bom.bom_line_ids},
      {k: float(v) for k, v in BOM_LINES.items()})
direct_cost = sum(parts_t[n].standard_price * q for n, q in BOM_LINES.items())
check("lab03", "Chapter 8 direct material cost per bike (RM)", direct_cost, 470.0)

everything = {**parts, "Road Bike": bike}
stock_before = stock_table(everything)
mo = make(PLANNER, bike, bom, 5)
check("lab03", "MO for 5 is confirmed, Planner responsible, components reserved",
      [mo.state, mo.user_id.name, mo.reservation_state], ["confirmed", "Production Planner", "assigned"])
check("lab03", "MO component demand is BOM x 5", {m.product_id.name: m.product_uom_qty for m in mo.move_raw_ids},
      {k: float(v) for k, v in QTY.items()})
finish(mo)
stock_after_mo = stock_table(everything)
check("lab03", "MO is Done", mo.state, "done")
check("lab03", "stock change matches BOM x 5",
      {k: stock_after_mo[k] - stock_before[k] for k in everything},
      {"Aluminium Frame": -5.0, "Rubber Tires": -10.0, "Brake Set": -5.0, "Gear Set": -5.0, "Bicycle Chain": -5.0, "Road Bike": 5.0})
note("lab03", "mo", mo.name)
note("lab03", "stock_before_mo", stock_before)
note("lab03", "stock_after_mo", stock_after_mo)

# ---------------------------------------------------------------- Lab 4
stage("Lab 4: customer, opportunity, pipeline, quotation")
customer = env["res.partner"].with_user(SM).create({
    "name": "Seri Iskandar Cycling Club", "is_company": True, "customer_rank": 1,
    "city": "Seri Iskandar", "state_id": perak.id, "country_id": malaysia.id,
})
check("lab04", "customer is a company contact", customer.is_company, True)
Stage = env["crm.stage"]
lead = env["crm.lead"].with_user(SM).create({
    "name": "Road Bike Order - Seri Iskandar Cycling Club", "type": "opportunity",
    "partner_id": customer.id, "expected_revenue": 5000, "user_id": SM.id,
})
check("lab04", "opportunity holds customer, Sales Manager, RM 5,000",
      [lead.partner_id.name, lead.user_id.name, lead.expected_revenue],
      ["Seri Iskandar Cycling Club", "Sales Manager", 5000.0])
trail = [lead.stage_id.name]
for name in ["Qualified", "Proposition"]:
    lead.stage_id = Stage.search([("name", "=", name)], limit=1)
    trail.append(lead.stage_id.name)
check("lab04", "pipeline stages", trail, ["New", "Qualified", "Proposition"])
lead.message_post(body="Customer requested 5 Road Bikes.", subtype_xmlid="mail.mt_note")
lead.activity_schedule("mail.mail_activity_data_todo", summary="Follow up on the five-bike requirement", user_id=SM.id)
check("lab04", "internal note and follow-up activity recorded",
      ["Customer requested 5 Road Bikes." in " ".join(lead.message_ids.mapped("body")), len(lead.activity_ids)], [True, 1])

context = lead.action_new_quotation()["context"]
quote = env["sale.order"].with_user(SM).with_context(**context).create({
    "partner_id": customer.id,
    "order_line": [(0, 0, {"product_id": bike.id, "product_uom_qty": 5})],
})
line = quote.order_line
check("lab04", "quotation links to the opportunity, same customer and salesperson",
      [quote.opportunity_id.id, quote.partner_id.id, quote.user_id.name], [lead.id, customer.id, "Sales Manager"])
check("lab04", "5 Road Bikes at RM 1,000, untaxed RM 5,000",
      [line.product_uom_qty, line.price_unit, quote.amount_untaxed], [5.0, 1000.0, 5000.0])
note("lab04", "quotation", {"name": quote.name, "untaxed": quote.amount_untaxed, "tax": quote.amount_tax, "total": quote.amount_total})

# Lab 4 verification: change the quantity, reconcile, change it back.
line.product_uom_qty = 6
changed = {"untaxed_at_qty_6": quote.amount_untaxed, "expected_revenue_after_change": lead.expected_revenue}
line.product_uom_qty = 5
check("lab04", "changing quantity recalculates the quote but not expected revenue",
      changed, {"untaxed_at_qty_6": 6000.0, "expected_revenue_after_change": 5000.0})
check("lab04", "quote restored to RM 5,000", quote.amount_untaxed, 5000.0)

# ---------------------------------------------------------------- Lab 5
stage("Lab 5: order to cash")
quote.action_confirm()
check("lab05", "quotation became a Sales Order", quote.state, "sale")
delivery = quote.picking_ids
check("lab05", "one linked Delivery", len(delivery), 1)
delivery = delivery.with_user(PLANNER)
retrying(delivery.action_assign)
check("lab05", "5 Road Bikes reserved", [delivery.state, delivery.move_ids.product_uom_qty], ["assigned", 5.0])
bikes_before = on_hand(bike)
receive(delivery)
check("lab05", "Delivery is Done", delivery.state, "done")
check("lab05", "Road Bike stock before and after", [bikes_before, on_hand(bike)], [5.0, 0.0])

lead.with_user(SM).action_set_won()
check("lab04", "opportunity marked Won after the order is confirmed", lead.stage_id.name, "Won")

wizard = env["sale.advance.payment.inv"].with_user(SM).with_context(
    active_model="sale.order", active_ids=quote.ids, active_id=quote.id
).create({"advance_payment_method": "delivered"})
wizard.create_invoices()
invoice = quote.invoice_ids
check("lab05", "one invoice created from the Sales Order, in Draft", [len(invoice), invoice.state], [1, "draft"])
inv_line = invoice.invoice_line_ids
check("lab05", "customer, product, quantity and price carried forward",
      [invoice.partner_id.id, inv_line.product_id.id, inv_line.quantity, inv_line.price_unit],
      [customer.id, bike.id, 5.0, 1000.0])
invoice.with_user(ACCT).action_post()
check("lab05", "invoice is Posted, unpaid", [invoice.state, invoice.payment_state], ["posted", "not_paid"])
check("lab05", "untaxed invoice amount (RM)", invoice.amount_untaxed, 5000.0)
note("lab05", "invoice_amounts", {"untaxed": invoice.amount_untaxed, "tax": invoice.amount_tax,
                                  "total": invoice.amount_total, "taxes": inv_line.tax_ids.mapped("name")})

register = env["account.payment.register"].with_user(ACCT).with_context(
    active_model="account.move", active_ids=invoice.ids
).create({})
note("lab05", "payment_journal", register.journal_id.name)
register.action_create_payments()
invoice.invalidate_recordset()
check("lab05", "invoice is Paid or In Payment", invoice.payment_state in ("paid", "in_payment"), True)
check("lab05", "nothing left to pay", invoice.amount_residual, 0.0)
payment = env["account.payment"].search([("invoice_ids", "in", invoice.ids)], limit=1)
note("lab05", "documents", {
    "sales_order": quote.name, "delivery": delivery.name, "invoice": invoice.name,
    "payment": payment.name, "payment_amount": payment.amount, "payment_state": invoice.payment_state,
})
stage("Capstone: stock at the end of the story")
stock_end = stock_table(everything)
check("capstone", "stock pattern after receipts, MO and delivery", stock_end,
      {k: 0.0 for k in everything})
note("capstone", "final_stock", stock_end)

# ---------------------------------------------------------------- Lab 2
stage("Lab 2: one customer traced through linked records")
trace = {
    "opportunity": [lead.name, lead.partner_id.id],
    "sales_order": [quote.name, quote.partner_id.id],
    "delivery": [delivery.name, delivery.partner_id.id],
    "invoice": [invoice.name, invoice.partner_id.id],
    "payment": [payment.name, payment.partner_id.id],
}
note("lab02", "customer_id_on_each_record", trace)
check("lab02", "all five records point at one customer record", {v[1] for v in trace.values()} == {customer.id}, True)
check("lab02", "there is one customer record of that name",
      env["res.partner"].search_count([("name", "=", customer.name)]), 1)
check("lab02", "documents are linked, not just alike",
      [quote.opportunity_id == lead, delivery.sale_id == quote, quote in invoice.invoice_line_ids.sale_line_ids.order_id],
      [True, True, True])
OWNERS = {"customer": ("res.partner", "base"), "opportunity": ("crm.lead", "crm"),
          "quotation": ("sale.order", "sale"), "purchase order": ("purchase.order", "purchase"),
          "receipt": ("stock.picking", "stock"), "BOM": ("mrp.bom", "mrp"),
          "manufacturing order": ("mrp.production", "mrp"), "delivery": ("stock.picking", "stock"),
          "invoice": ("account.move", "account"), "employee": ("hr.employee", "hr")}
for record, (model, module) in OWNERS.items():
    owner = env["ir.model"].search([("model", "=", model)]).modules
    check("lab02", f"{record} ({model}) is defined by {module}", module in [m.strip() for m in owner.split(",")], True)

# ---------------------------------------------------------------- Lab 6 Part E
stage("Lab 6 E: reporting menus and what they supply")
# load_web_menus is what the web client draws. Searching ir.ui.menu is not enough:
# the Manufacturing > Reporting record exists, but Odoo does not show it, even to
# the administrator, so a search would report a menu nobody can open.
menus = env["ir.ui.menu"].load_web_menus(False)


def visible_children(parent):
    return [menus[c]["name"] for c in parent["children"]]


def app_menu(name):
    return next(m for key, m in menus.items() if key != "root" and m["name"] == name and m["appID"] == m["id"])


def submenu(parent, name):
    return next((menus[c] for c in parent["children"] if menus[c]["name"] == name), None)


for app in ["Sales", "Inventory"]:
    reporting = submenu(app_menu(app), "Reporting")
    check("lab06", f"{app} > Reporting is visible", reporting is not None, True)
    note("lab06", f"{app}_reporting_items", visible_children(reporting))
manufacturing = app_menu("Manufacturing")
note("lab06", "Manufacturing_menu", visible_children(manufacturing))
check("lab06", "Manufacturing > Reporting is hidden by default, as Lab 6 now says",
      submenu(manufacturing, "Reporting") is None, True)
check("lab06", "production output is at Manufacturing > Operations > Manufacturing Orders",
      "Manufacturing Orders" in visible_children(submenu(manufacturing, "Operations")), True)
history = env["sale.report"]._read_group([("state", "=", "sale")], ["product_id"], ["product_uom_qty:sum", "price_subtotal:sum"])
check("lab06", "Sales report holds the sales history (Road Bike, qty, untaxed)",
      [[p.name, q, a] for p, q, a in history], [["Road Bike", 5.0, 5000.0]])
done = env["mrp.production"]._read_group([("state", "=", "done")], ["product_id"], ["product_qty:sum"])
check("lab06", "Manufacturing report holds actual production", [[p.name, q] for p, q in done], [["Road Bike", 5.0]])
check("lab06", "Inventory holds the starting stock for planning", on_hand(bike), 0.0)

# ---------------------------------------------------------------- Lab 8
stage("Lab 8 A, F: organisation and roles on transactions")
# A new Odoo database also has its own "Administration" department, holding the
# Administrator employee. The labs do not use it, so it is left alone and not counted.
headcount = {d.name: d.total_employee for d in departments.values()}
check("lab08", "headcount by department", headcount,
      {"Sales and Marketing": 1, "Accounting and Finance": 1, "Supply Chain": 2, "Human Resources": 1})
note("lab08", "all_departments_in_odoo", env["hr.department"].search([]).mapped("name"))
check("lab08", "Planner reports to the Supply Chain head", employees["Production Planner"].parent_id.name, "Purchasing Officer")
roles_on_docs = {
    "Sales Manager on opportunity and Sales Order": [lead.user_id.name, quote.user_id.name] == ["Sales Manager"] * 2,
    "Purchasing Officer is Buyer on every PO": set(o.user_id.name for o in orders.values()) == {"Purchasing Officer"},
    "Production Planner is Responsible on the MO": mo.user_id.name == "Production Planner",
    "Accountant created the payment": payment.create_uid.name == "Accountant",
}
for what, value in roles_on_docs.items():
    check("lab08", what, value, True)
check("lab08", "HR Officer has no document, so holds a role but owns no transaction",
      env["sale.order"].search_count([("user_id", "=", HR.id)]) + env["purchase.order"].search_count([("user_id", "=", HR.id)]), 0)

# ---------------------------------------------------------------- Lab 7 verification
stage("Lab 7 verification: partial receipt, backorder, bill")
partial = buy(BUYER, vendors["Ipoh Metal Supply"], [(frame, 4)])
first = partial.picking_ids
receive(first.with_user(BUYER), {frame.id: 3})
backorder = partial.picking_ids - first
check("lab07", "receiving 3 of 4 leaves a backorder of 1",
      [first.state, len(backorder), backorder.move_ids.product_uom_qty, backorder.state],
      ["done", 1, 1.0, "assigned"])
partial.invalidate_recordset()
line = partial.order_line
partial.action_create_invoice()
bill = partial.invoice_ids
check("lab07", "ordered, received and billed quantities",
      [line.product_qty, line.qty_received, bill.invoice_line_ids.quantity], [4.0, 3.0, 3.0])
check("lab07", "initial fill rate is 75 percent", line.qty_received / line.product_qty, 0.75)
check("lab07", "ordered equals received plus outstanding",
      line.product_qty, line.qty_received + backorder.move_ids.product_uom_qty)
note("lab07", "partial_exercise", {"po": partial.name, "receipt": first.name, "backorder": backorder.name,
                                   "bill_state": bill.state})

# ---------------------------------------------------------------- Lab 3 verification
stage("Lab 3 verification: component shortage and corrective receipt")
short = make(PLANNER, bike, bom, 1)
state_short = short.reservation_state
missing = sorted(m.product_id.name for m in short.move_raw_ids if m.state != "assigned")
check("lab03", "with only frames on hand the MO cannot start", state_short == "assigned", False)
check("lab03", "the components it waits for", missing, ["Bicycle Chain", "Brake Set", "Gear Set", "Rubber Tires"])
note("lab03", "shortage_reservation_state", state_short)
fix_a = buy(BUYER, vendors["RubberWheel Co."], [(parts["Rubber Tires"], 2)])
fix_b = buy(BUYER, vendors["BikeParts Supplier"], [(parts[n], 1) for n in ["Brake Set", "Gear Set", "Bicycle Chain"]])
retrying(short.action_assign)
check("lab03", "a confirmed PO does not clear the shortage", short.reservation_state == "assigned", False)
receive(fix_a.picking_ids.with_user(BUYER))
receive(fix_b.picking_ids.with_user(BUYER))
retrying(short.action_assign)
check("lab03", "after the corrective receipts the components are reserved", short.reservation_state, "assigned")
finish(short)
check("lab03", "the shortage MO is Done", short.state, "done")
final = stock_table(everything)
check("lab03", "final stock after both exercises", final,
      {"Aluminium Frame": 2.0, "Rubber Tires": 0.0, "Brake Set": 0.0, "Gear Set": 0.0, "Bicycle Chain": 0.0, "Road Bike": 1.0})
note("lab03", "shortage_mo", short.name)

# ---------------------------------------------------------------- finish
env.cr.commit()
passed = sum(c["ok"] for lab in evidence.values() for c in lab["checks"])
total = sum(len(lab["checks"]) for lab in evidence.values())
evidence = {k: evidence[k] for k in sorted(evidence)}
(RESULTS / "evidence.json").write_text(json.dumps(evidence, indent=2, default=str), encoding="utf-8")
print(f"\nRESULT: {passed}/{total} checks passed. Evidence: {RESULTS / 'evidence.json'}")
for lab, data in evidence.items():
    print(f"  {lab}: {sum(c['ok'] for c in data['checks'])}/{len(data['checks'])}")
if failures:
    print("FAILED:")
    print("\n".join("  " + f for f in failures))
    raise SystemExit(1)
