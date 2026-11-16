// Enterprise Resource Planning: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Enterprise Resource Planning],
  running-head: [Enterprise Resource Planning],
  outline: [ERP concepts, business processes, and integrated Odoo 19 Community Edition practicals for West End Bicycles.],
  lab-total: 8,
  contents: (part: 1.20em, chapter: 0.50em, lab: 0.55em),
  listing: "terminal",
)
#cover()
#contents()
#include "chapters/course-map.typ"
#show: mainmatter

#include "chapters/00-toolkit.typ"

#part[ERP Foundations and Business Processes]
#include "chapters/01-business-processes.typ"
#include "chapters/02-erp-development.typ"

#part[Customer, Sales, and Revenue]
#include "chapters/03-sales-order-process.typ"
#include "chapters/04-crm.typ"

#part[Planning, Production, and Supply Chain]
#include "chapters/05-production-planning.typ"
#include "chapters/06-forecasting-sop.typ"
#include "chapters/07-supply-chain-mrp.typ"

#part[Finance, People, and Process Improvement]
#include "chapters/08-accounting-integration.typ"
#include "chapters/09-human-resources.typ"
#include "chapters/10-process-modeling-implementation.typ"

#part[Integrated Odoo Practicals]
#include "labs/01-business-process-odoo.typ"
#include "labs/02-erp-development-odoo.typ"
#include "labs/03-production-planning-odoo.typ"
#include "labs/04-crm-odoo.typ"
#include "labs/05-sales-order-odoo.typ"
#include "labs/06-forecast-sop-odoo.typ"
#include "labs/07-scm-odoo.typ"
#include "labs/08-hr-process-odoo.typ"

#include "chapters/capstone-odoo.typ"
#include "appendices/odoo-quick-reference.typ"
#include "appendices/source-map.typ"
