// Operating Systems: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Operating Systems],
  running-head: [Operating Systems Notes],
  outline: [A step-by-step path from the Linux command line and process model through CPU scheduling, concurrency, memory management, and file systems, with one practical lab paired to each core chapter.],
  lab-total: 10,
)
#cover()
#contents()
#include "chapters/course-map.typ"
#show: mainmatter

#part[Orientation and Tools]
#include "chapters/00-getting-started-linux-wsl.typ"
#include "chapters/01-operating-systems-at-a-glance.typ"

#part[Processes and the Command Line]
#include "chapters/02-linux-processes-files-and-system-calls.typ"
#include "labs/01-linux-processes-and-directories.typ"

#include "chapters/02-files-metadata-and-cli-utilities.typ"
#include "labs/02-file-and-directory-utilities.typ"

#include "chapters/03-shell-scripting-and-command-line-automation.typ"
#include "labs/03-shell-scripting.typ"

#part[CPU, Concurrency, and Resource Management]
#include "chapters/04-cpu-scheduling.typ"
#include "labs/04-cpu-scheduling.typ"

#include "chapters/05-interprocess-communication-and-synchronization.typ"
#include "labs/05-synchronization-and-shared-memory.typ"

#include "chapters/06-threads-and-deadlocks.typ"
#include "labs/06-threads-and-deadlocks.typ"

#part[Memory Management]
#include "chapters/07-contiguous-memory-allocation.typ"
#include "labs/07-memory-allocation.typ"

#include "chapters/08-virtual-memory-and-page-replacement.typ"
#include "labs/08-virtual-memory-and-page-replacement.typ"

#part[File Systems and Storage]
#include "chapters/09-directory-structures.typ"
#include "labs/09-directory-visualization.typ"

#include "chapters/10-file-organization-and-allocation.typ"
#include "labs/10-file-records-and-indexed-allocation.typ"

#include "chapters/11-exam-map-and-capstone.typ"
