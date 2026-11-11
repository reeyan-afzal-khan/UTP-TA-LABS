#import "/.shared/typst/utp.typ": *
#show: book.with(title: [Operating Systems], summary: [A step-by-step path from the Linux command line and process model through CPU scheduling, concurrency, memory management, and file systems, with one practical lab paired to each core chapter.], lab-total: 10)

#cover(title: [Operating Systems], summary: [A step-by-step path from the Linux command line and process model through CPU scheduling, concurrency, memory management, and file systems, with one practical lab paired to each core chapter.])
#outline(depth: 1)
#pagebreak()
#include "chapters/course-map.typ"
#stage[Orientation and Tools] 
#include "/OPERATING SYSTEMS/chapters/00-getting-started-linux-wsl.typ"
 
#include "/OPERATING SYSTEMS/chapters/01-operating-systems-at-a-glance.typ"


#stage[Processes and the Command Line] 
#include "/OPERATING SYSTEMS/chapters/02-linux-processes-files-and-system-calls.typ"
 
#include "/OPERATING SYSTEMS/labs/01-linux-processes-and-directories.typ"



#include "/OPERATING SYSTEMS/chapters/02-files-metadata-and-cli-utilities.typ"
 
#include "/OPERATING SYSTEMS/labs/02-file-and-directory-utilities.typ"



#include "/OPERATING SYSTEMS/chapters/03-shell-scripting-and-command-line-automation.typ"
 
#include "/OPERATING SYSTEMS/labs/03-shell-scripting.typ"


#stage[CPU, Concurrency, and Resource Management] 
#include "/OPERATING SYSTEMS/chapters/04-cpu-scheduling.typ"
 
#include "/OPERATING SYSTEMS/labs/04-cpu-scheduling.typ"



#include "/OPERATING SYSTEMS/chapters/05-interprocess-communication-and-synchronization.typ"
 
#include "/OPERATING SYSTEMS/labs/05-synchronization-and-shared-memory.typ"



#include "/OPERATING SYSTEMS/chapters/06-threads-and-deadlocks.typ"
 
#include "/OPERATING SYSTEMS/labs/06-threads-and-deadlocks.typ"


#stage[Memory Management] 
#include "/OPERATING SYSTEMS/chapters/07-contiguous-memory-allocation.typ"
 
#include "/OPERATING SYSTEMS/labs/07-memory-allocation.typ"



#include "/OPERATING SYSTEMS/chapters/08-virtual-memory-and-page-replacement.typ"
 
#include "/OPERATING SYSTEMS/labs/08-virtual-memory-and-page-replacement.typ"


#stage[File Systems and Storage] 
#include "/OPERATING SYSTEMS/chapters/09-directory-structures.typ"
 
#include "/OPERATING SYSTEMS/labs/09-directory-visualization.typ"



#include "/OPERATING SYSTEMS/chapters/10-file-organization-and-allocation.typ"
 
#include "/OPERATING SYSTEMS/labs/10-file-records-and-indexed-allocation.typ"



#include "/OPERATING SYSTEMS/chapters/11-exam-map-and-capstone.typ"

