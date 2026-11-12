// 0.Git-Repo-Submission: the book. Settings first, then the chapters and labs in teaching order.
#import "/.shared/typst/utp.typ": *
#show: book.with(
  title: [Git and GitHub Setup],
  running-head: [Git and GitHub Setup],
  outline: [Install Git, configure SSH authentication, and prepare a course repository for submission.],
)
#cover()
#contents()
#show: mainmatter

#include "chapters/01-introduction.typ"
#include "chapters/02-installing-git-and-ssh.typ"
#include "chapters/03-making-the-repo.typ"
