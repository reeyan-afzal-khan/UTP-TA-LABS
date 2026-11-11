#import "/.shared/typst/utp.typ": *
#show: book.with(title: [Enterprise Resource Planning], summary: [ERP concepts, business processes, and integrated Odoo 19 Community Edition practicals for West End Bicycles.], lab-total: 8)

#cover(title: [Enterprise Resource Planning], summary: [ERP concepts, business processes, and integrated Odoo 19 Community Edition practicals for West End Bicycles.])
#outline(depth: 1)
#pagebreak()
#include "chapters/course-map.typ"

#include "/ENTERPRISE RESOURCE PLANNING/chapters/00-toolkit.typ"


#stage[ERP Foundations and Business Processes] 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/01-business-processes.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/02-erp-development.typ"


#stage[Customer, Sales, and Revenue] 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/03-sales-order-process.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/04-crm.typ"


#stage[Planning, Production, and Supply Chain] 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/05-production-planning.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/06-forecasting-sop.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/07-supply-chain-mrp.typ"


#stage[Finance, People, and Process Improvement] 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/08-accounting-integration.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/09-human-resources.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/chapters/10-process-modeling-implementation.typ"


#stage[Integrated Odoo Practicals] 
#include "/ENTERPRISE RESOURCE PLANNING/labs/01-business-process-odoo.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/labs/02-erp-development-odoo.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/labs/03-production-planning-odoo.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/labs/04-crm-odoo.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/labs/05-sales-order-odoo.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/labs/06-forecast-sop-odoo.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/labs/07-scm-odoo.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/labs/08-hr-process-odoo.typ"



#include "/ENTERPRISE RESOURCE PLANNING/chapters/capstone-odoo.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/appendices/odoo-quick-reference.typ"
 
#include "/ENTERPRISE RESOURCE PLANNING/appendices/source-map.typ"

