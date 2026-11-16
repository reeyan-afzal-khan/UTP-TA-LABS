// 0.Git-Repo-Submission: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Git and GitHub Setup],
  running-head: [Git and GitHub Setup],
  outline: [Install and configure SSH authentication, and prepare a course repository for submission; then learn how Git works and the advanced tools teams use every day: branching, merging, rebasing, undoing mistakes, searching history, and keeping a repository clean and secure.],
)
#cover()
#contents()
#show: mainmatter

#include "chapters/01-introduction.typ"

#part[Set Up and Submit]
#include "chapters/02-installing-git-and-ssh.typ"
#include "chapters/03-making-the-repo.typ"

#part[How Git Works]
#include "chapters/04-how-git-saves-work.typ"
#include "chapters/05-branches-and-merging.typ"
#include "chapters/06-remotes-and-collaboration.typ"

#part[Advanced Git]
#include "chapters/07-undoing-changes.typ"
#include "chapters/08-rebase-and-history.typ"
#include "chapters/09-investigating-history.typ"
#include "chapters/10-power-tools.typ"
#include "chapters/11-large-files-and-security.typ"

#include "appendices/git-quick-reference.typ"
