#import "/.shared/typst/utp.typ": *
#unit("appendices", "git-quick-reference")

// A fixed-width separator: justified table cells squeeze ordinary spaces beside code.
#let sep = [#h(0.35em)#text(fill: muted)[·]#h(0.35em)]

#chapter-star[Appendix A: Git Quick Reference]

Every command in this book, grouped by the job it does, followed by the words Git uses for the things it moves. The chapter column says where each command is explained.

#heading(depth: 2, numbering: none)[Commands that only look]

These change nothing, so you can run them at any time: `git status`, `git log`, `git diff`, `git show`, `git branch`, `git remote -v`, `git reflog`, `git blame`, `git grep`, `git stash list`, `git tag -l`.

#heading(depth: 2, numbering: none)[Start and configure]

#utptable[
  #tabularx(
    columns: (46%, 1fr, 9%),
    header: ([Command], [Job], [Ch.]),
    [`git config --global user.name "Your Name"`], [Set the name (and, with `user.email`, the e-mail) on your commits], [2],
    [`git init -b main`], [Turn the current folder into a repository], [3],
    [`git clone <url>`], [Copy a repository, with its whole history, into a new folder], [6],
    [`git remote add origin <url>`], [Link the repository to GitHub], [3],
    [`git config --global --list --show-origin`], [Show every setting and where it is defined], [10],
  )
]

#heading(depth: 2, numbering: none)[Save work]

#utptable[
  #tabularx(
    columns: (46%, 1fr, 9%),
    header: ([Command], [Job], [Ch.]),
    [`git add <file>`#(sep)`git add .`], [Stage one file#(sep)every change in this folder], [4],
    [`git add -p`], [Stage chosen parts of files], [4],
    [`git commit -m "message"`], [Save the staging area as a commit], [4],
    [`git diff`#(sep)`--staged`#(sep)`HEAD`], [Unstaged changes#(sep)staged changes#(sep)all changes since the last commit], [4],
    [`git log --oneline --graph --all`], [Draw every branch], [5],
  )
]

#heading(depth: 2, numbering: none)[Branch and merge]

#utptable[
  #tabularx(
    columns: (46%, 1fr, 9%),
    header: ([Command], [Job], [Ch.]),
    [`git switch -c <branch>`], [Create a branch here and move to it], [5],
    [`git switch <branch>`#(sep)`git switch -`], [Move to a branch#(sep)back to the previous one], [5],
    [`git merge <branch>`], [Bring another branch into the current one], [5],
    [`git merge --abort`], [Give up a conflicted merge], [5],
    [`git branch -d <branch>`#(sep)`-D`], [Delete a merged branch#(sep)any branch], [5],
    [`git rebase main`], [Replay this branch's commits on top of `main`], [8],
    [`git rebase -i main`], [Reword, squash, reorder or drop this branch's commits], [8],
    [`git cherry-pick -x <hash>`], [Copy one commit onto the current branch], [8],
  )
]

#heading(depth: 2, numbering: none)[Share]

#utptable[
  #tabularx(
    columns: (46%, 1fr, 9%),
    header: ([Command], [Job], [Ch.]),
    [`git fetch`], [Download commits; move only the `origin/...` notes], [6],
    [`git pull`], [Fetch, then merge or rebase into the current branch], [6],
    [`git push`#(sep)`git push -u origin <branch>`], [Upload commits#(sep)the first push of a new branch], [6],
    [`git push --force-with-lease`], [Overwrite #emph[your own] rewritten branch, safely], [6],
    [`git remote add upstream <url>`], [Name the original repository of a fork], [6],
    [`git push origin <tag>`], [Publish a tag], [10],
  )
]

#heading(depth: 2, numbering: none)[Undo]

#utptable[
  #tabularx(
    columns: (46%, 1fr, 9%),
    header: ([Command], [Job], [Ch.]),
    [`git restore <file>`], [Discard unstaged edits to a file (cannot be undone)], [7],
    [`git restore --staged <file>`], [Unstage, keeping the edits], [7],
    [`git restore --source=<hash> <file>`], [Bring back a file as it was in an older commit], [7],
    [`git commit --amend`], [Replace the last commit (unpushed only)], [7],
    [`git reset --soft`#(sep)`--mixed`#(sep)`--hard HEAD~1`], [Move the branch back one commit, keeping the changes staged#(sep)unstaged#(sep)not at all], [7],
    [`git revert <hash>`], [Add a commit that undoes an earlier one (safe after pushing)], [7],
    [`git reflog`], [Find any commit `HEAD` has been on, to recover it], [7],
    [`git clean -n` then `-f`], [List, then delete, untracked files], [7],
  )
]

#heading(depth: 2, numbering: none)[Investigate]

#utptable[
  #tabularx(
    columns: (46%, 1fr, 9%),
    header: ([Command], [Job], [Ch.]),
    [`git log main..feature`], [Commits on `feature` that `main` lacks], [9],
    [`git log --author= --since= --grep= -- <file>`], [Filter history by person, date, message or file], [9],
    [`git log -S "text"`], [Commits that added or removed `text`], [9],
    [`git blame -w -L 10,20 <file>`], [The last commit to change each line], [9],
    [`git bisect start`#(sep)`good`#(sep)`bad`#(sep)`run`#(sep)`reset`], [Binary-search for the commit that introduced a bug], [9],
  )
]

#heading(depth: 2, numbering: none)[Set aside and mark]

#utptable[
  #tabularx(
    columns: (46%, 1fr, 9%),
    header: ([Command], [Job], [Ch.]),
    [`git stash push -m "note"`#(sep)`pop`], [Shelve uncommitted work#(sep)bring it back], [10],
    [`git tag -a v1.0.0 -m "message"`], [Mark the current commit permanently], [10],
    [`git worktree add -b <branch> <folder>`], [Check out a second branch in another folder], [10],
    [`git lfs track "*.pt"`], [Store matching files with Git LFS], [11],
    [`git filter-repo --invert-paths --path <file>`], [Remove a file from every commit (after revoking any secret in it)], [11],
  )
]

#heading(depth: 2, numbering: none)[Words Git uses]

#utptable[
  #tabularx(
    columns: (22%, 1fr),
    styles: (navy-bold,),
    header: ([Term], [Meaning]),
    [Working folder], [The files you edit; Git's #emph[working tree]],
    [Staging area], [The changes packed for the next commit; Git's #emph[index]],
    [Commit], [A saved snapshot of the whole project, with author, date, message and parent(s), named by its hash],
    [Branch], [A movable label pointing at one commit; it moves forward when you commit on it],
    [`HEAD`], [The #emph[you are here] pin: normally points at the current branch],
    [Detached `HEAD`], [`HEAD` pointing straight at a commit instead of a branch],
    [Remote#(sep)origin], [Another copy of the repository#(sep)the default name of the one you cloned from],
    [`origin/main`], [Your computer's note of where `main` was on the remote at the last fetch, pull or push],
    [Upstream], [The remote branch a local branch pushes to and pulls from; also the usual name of a fork's original],
    [Fast-forward], [A merge that only moves a label forward, because one side had no new commits],
    [Merge commit], [A commit with two parents, recording where two branches joined],
    [Conflict], [Both sides changed the same lines; Git asks you to choose],
    [Rebase], [Replaying commits onto a new base, creating new commits with new hashes],
    [Pull request], [A GitHub page proposing that one branch be reviewed and merged into another],
    [Fork], [Your own GitHub copy of someone else's repository],
    [Tag], [A permanent label on one commit, used for releases and submissions],
    [Stash], [A shelf for uncommitted changes],
    [Reflog], [Your computer's private record of every position of `HEAD`],
  )
]
