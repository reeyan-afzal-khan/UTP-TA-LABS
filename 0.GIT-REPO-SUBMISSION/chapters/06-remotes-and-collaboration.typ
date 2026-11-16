#import "/.shared/typst/utp.typ": *
#import "git-figures.typ": *
#unit("chapters", "06-remotes-and-collaboration")

= Remotes, pull requests and teamwork <ch:collaboration>

#chapterguide[#chapref(<ch:branches>): branches, `HEAD`, merging and conflicts. An SSH key registered with GitHub (#chapref(<ch:git-ssh-setup>)).][explain what `origin/main` is and why it can be out of date; choose between `fetch`, `pull` and `push` and read their output; fix a rejected push and a #emph[divergent branches] error; run the feature-branch workflow from branch to merged pull request; review a teammate's pull request; contribute to a repository you cannot push to through a fork; and force-push safely when you must.]

Until now, GitHub has been a backup. This chapter makes it a meeting place. Your teammate clones the project, both of you work on branches, and every change reaches `main` through a #term[pull request] that someone else has read.

== Remotes and remote-tracking branches <sec:remotes>

A #term[remote] is a named address of another copy of the repository. `git clone` and `git remote add origin ...` (#chapref(<ch:repo-submission>)) both create one called `origin`:

```terminal
$ git remote -v
origin  git@github.com:USERNAME/todo-app.git (fetch)
origin  git@github.com:USERNAME/todo-app.git (push)
```

For every branch on the remote, your computer keeps a #term[remote-tracking branch] such as `origin/main`. It is a #emph[note]: where `main` was on GitHub the last time your computer talked to GitHub. Git never updates the note by itself. Only `git fetch`, `git pull` and `git push` move it, so `Your branch is up to date with 'origin/main'` means #emph[up to date with the note], not necessarily with GitHub.

`git branch -vv` shows each local branch, the remote branch it tracks, and how far apart they are:

```terminal
$ git branch -vv
* feature/login 4c2a9e1 [origin/feature/login: ahead 1] Add login form
  main          7d3b2f0 [origin/main: behind 2] Add README
```

#emph[Ahead 1] means one commit here that GitHub has not received; #emph[behind 2] means two commits on GitHub (as of the last fetch) that you have not brought in. `git branch -a` lists remote-tracking branches too, and `git remote show origin` prints a full report.

== Fetch, pull and push <sec:fetch-pull-push>

#utptable[
  #tabularx(
    columns: (38%, 1fr),
    header: ([Command], [What it does]),
    [`git fetch`], [Downloads new commits from `origin` and moves the `origin/...` notes. Never changes your branches or your files, so it is always safe],
    [`git pull`], [`git fetch`, then brings `origin/<branch>` into your current branch: a fast-forward, a merge or a rebase, depending on your settings],
    [`git pull --ff-only`], [Pulls only if your branch can fast-forward; stops otherwise],
    [`git pull --rebase`], [Fetches, then replays your local commits on top of the fetched ones (#chapref(<ch:rebase>))],
    [`git push`], [Uploads your current branch's new commits and moves the branch on GitHub],
    [`git push -u origin feature/x`], [The first push of a new branch: creates it on GitHub and remembers it as the branch's upstream, so later a plain `git push` works],
    [`git push origin --delete feature/x`], [Deletes the branch on GitHub],
  )
]

Read the transfer line that every push and pull prints. `7d3b2f0..4c2a9e1  main -> main` means the branch moved from the first commit to the second; the name on the left of the arrow is the sender's branch, the one on the right the receiver's.

Two settings save typing and confusion. The first makes `git push` on a new branch create its upstream automatically (Git 2.37 or later); the second removes `origin/...` notes for branches that were deleted on GitHub:

```terminal
git config --global push.autoSetupRemote true
git config --global fetch.prune true
```

=== When GitHub refuses your push

```terminal
$ git push
To github.com:USERNAME/todo-app.git
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'github.com:USERNAME/todo-app.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. This is usually caused by another repository pushing to
hint: the same ref. ...
```

Your teammate pushed first. GitHub will not let your push throw their commits away, so bring their work in, then push again: `git pull`, resolve any conflict as in #secref(<sec:conflicts>), then `git push`.

#warning[
  `git push --force` would make the push succeed by #emph[deleting your teammate's commits from GitHub]. Never force-push to `main` or any branch someone else uses. #secref(<sec:force-with-lease>) shows the one safe form, for your own branches.
]

=== When `git pull` stops at #emph[divergent branches]

If both you and GitHub have new commits on the same branch, the histories have #term[diverged]. Recent versions of Git refuse to choose how to combine them for you:

```terminal
hint: You have divergent branches and need to specify how to reconcile them.
hint: You can do so by running one of the following commands sometime before
hint: your next pull:
hint:
hint:   git config pull.rebase false  # merge
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
...
fatal: Need to specify how to reconcile divergent branches.
```

#utpfig([Diverged histories. (a) GitHub received your teammate's commit E. (b) After `git fetch` your computer knows about E through the note `origin/main`, while your own `main` has commit D. A pull must merge D and E, or replay D on top of E.], label: <fig:diverged>)[
  #canvas({
    node((1.95, 2.15), [(a) GitHub], ..gtitle)
    for (i, l) in ("A", "B", "C").enumerate() { node((i * 1.3, 0), l, name: "g" + l, ..gcommit) }
    node((3.9, 0), [E], name: "gE", ..gcommit)
    connect("gA", "gB", ..gparent)
    connect("gB", "gC", ..gparent)
    connect("gC", "gE", ..gparent)
    glabel("gE", [main], "gmain")

    node((8.25, 2.15), [(b) Your computer, after `git fetch`], ..gtitle)
    for (i, l) in ("A", "B", "C").enumerate() { node((6.3 + i * 1.3, 0), l, name: "l" + l, ..gcommit) }
    node((10.2, 0.6), [E], name: "lE", ..gdim)
    node((10.2, -0.6), [D], name: "lD", ..gnew)
    connect("lA", "lB", ..gparent)
    connect("lB", "lC", ..gparent)
    connect("lC", "lE", ..gparentdim)
    connect("lC", "lD", ..gparent)
    glabel("lE", [origin/main], "lom", style: gremote)
    node(right-of("lD", 0.25), [main], name: "lmain", ..gbranch)
    connect("lmain", "lD", ..gptr)
    node(right-of("lmain", 0.25), [HEAD], name: "lhead", ..ghead)
    connect("lhead", "lmain", ..gptrhead)
  })
]

Set the behaviour once. While you are learning, merging is the easiest to understand, because nothing you committed changes; after #chapref(<ch:rebase>) you may prefer rebasing, which keeps the history in one straight line.

```terminal
git config --global pull.rebase false     # pull merges (recommended to start)
```

If a text editor opens asking for a merge message, save and close it to accept the default.

== Clone a repository and add a collaborator <sec:clone>

Your teammate gets their own complete copy, with every commit, using `git clone`:

```terminal
git clone git@github.com:USERNAME/todo-app.git
cd todo-app
```

Clone creates the folder, sets up `origin`, and checks out `main` already tracking `origin/main`, so their first push is just `git push`. To let them push at all, add them on GitHub: open the repository, choose #strong[Settings] #sym.arrow.r #strong[Collaborators], select #strong[Add people], and enter their username. They must accept the e-mailed invitation.

#exercises[
  Be your own teammate. Clone your `todo-app` repository a second time into a different folder, for example `todo-app-teammate`. Commit and push a change from one folder, then run `git status`, `git fetch`, `git status` again and `git pull` in the other. Watch `origin/main` move, and notice that the first `git status` did not know about the new commit.
]

== The feature-branch workflow <sec:feature-workflow>

Teams that use GitHub almost always work like this. Nobody commits directly to `main`; each piece of work gets a branch and arrives through a pull request.

#tip[
  #listopts(leftmargin: 1.7em, itemsep: 0.35em, topsep: 0.3em)[
    + Start from an up-to-date `main`: `git switch main`, then `git pull`.
    + Create a branch for one piece of work: `git switch -c feature/dark-theme`.
    + Commit as you go, in small steps, with clear messages.
    + Push the branch: `git push -u origin feature/dark-theme`.
    + Open a pull request on GitHub from your branch into `main`.
    + Answer the review by committing on the same branch and pushing again; the pull request updates itself.
    + Once it is approved, merge it on GitHub and delete the branch there.
    + Back on your computer: `git switch main`, `git pull`, `git branch -d feature/dark-theme`.
  ]
]

== Pull requests <sec:pull-requests>

A pull request asks for one branch to be reviewed and then merged into another. Despite the name, it does not download anything to your computer; it is a page on GitHub where the change is discussed.

=== Open one

After your first push of a branch, Git prints a link (`remote: Create a pull request for 'feature/dark-theme' on GitHub by visiting: ...`), and the repository page shows a #strong[Compare & pull request] button. Either one opens the form:

- #strong[base] is the branch the work goes into (usually `main`); #strong[compare] is your branch.
- The #strong[title] says what the change does, like a commit subject.
- The #strong[description] says why, how you tested it, and what the reviewer should look at. Writing `Closes #12` links issue 12 and closes it when the pull request merges.
- Choose #strong[Create draft pull request] if the work is not ready for review yet but you want early comments.

=== Review one

Open the pull request's #strong[Files changed] tab. Removed lines are red and added lines green, as in `git diff`. Click the #strong[+] beside any line to comment on it; to propose an exact fix, use the #strong[suggestion] button, which the author can accept with one click. When you are done, choose #strong[Review changes] and one of #strong[Comment], #strong[Approve] or #strong[Request changes].

#note[
  Review what the change #emph[does], not only what it says. In the to-do app, a dark theme that changed only the background passed every check, yet the teal heading it never touched became unreadable on the dark page. A second pair of eyes catches what the author stopped seeing.
]

=== Merge one

GitHub offers three ways to merge, and a repository's owner can allow any of them:

#utptable[
  #tabularx(
    columns: (24%, 1fr, 30%),
    styles: (navy-bold,),
    header: ([Button], [What lands on `main`], [Choose it when]),
    [Create a merge commit], [All of the branch's commits, plus a merge commit joining them. The same as `git merge --no-ff`], [You want to see each feature as one join in the graph],
    [Squash and merge], [One new commit containing the whole change; the branch's individual commits are not kept], [The branch has many small or messy commits],
    [Rebase and merge], [Each commit replayed on top of `main` with a new hash; no merge commit], [You want a straight-line history and every commit is tidy],
  )
]

#warning[
  After #emph[Squash and merge] or #emph[Rebase and merge], your local branch's commits are not ancestors of `main`, so `git branch -d feature/dark-theme` refuses with #emph[not fully merged]. Check on GitHub that the pull request shows #emph[Merged], then delete the local branch with `git branch -D feature/dark-theme`.
]

=== Keep a long-lived pull request up to date

If `main` moves while your pull request is open, GitHub may report conflicts or that the branch is out of date. Bring `main` into your branch and push:

```terminal
git switch feature/dark-theme
git fetch
git merge origin/main        # resolve any conflicts, then commit
git push
```

The #strong[Update branch] button on the pull request does the same merge on GitHub. #chapref(<ch:rebase>) shows the alternative, rebasing the branch onto `main`.

#note[
  #strong[The GitHub CLI.] The `gh` command does the same work from the terminal: `gh pr create --fill` opens a pull request using your commit messages, `gh pr checkout 7` downloads pull request 7 to review it locally, `gh pr view --web` opens it in the browser, and `gh pr merge` merges it. Install it from #link("https://cli.github.com")[cli.github.com] and sign in once with `gh auth login`.
]

== Contribute through a fork <sec:forks>

To contribute to a repository you cannot push to (an open-source project, or a lecturer's template), you #term[fork] it: GitHub makes a copy under your own account. You push to your fork and open a pull request from it to the original, which by convention is called `upstream`.

#utpfig([Working with a fork. You push only to your fork (`origin`); your changes reach the original (`upstream`) through a pull request; and you bring the original's new commits down with `git fetch upstream`.], label: <fig:fork>)[
  #canvas({
    node((0, 1.7), [#strong[Original repository] \ #fsize("script")[remote `upstream`]], name: "up", ..gremoteplace)
    node((7.4, 1.7), [#strong[Your fork] \ #fsize("script")[remote `origin`]], name: "fork", ..gremoteplace)
    node((3.7, -0.9), [#strong[Your computer] \ #fsize("script")[your clone]], name: "pc", ..gplace)
    connect((1.6, 1.95), (5.8, 1.95), ..gforward)
    node((3.7, 2.25), [#strong[Fork] on GitHub, once], ..gcmdlabel)
    connect((5.8, 1.45), (1.6, 1.45), ..gback)
    node((3.7, 1.45), [pull request], ..gcmdlabel)
    connect((0.6, 1.05), (2.35, -0.6), ..gback)
    node((0.55, 0.05), gcmd[git fetch upstream], ..gcmdlabel)
    connect((5.05, -0.6), (6.8, 1.05), ..gforward)
    node((6.95, 0.05), gcmd[git push origin], ..gcmdlabel)
  })
]

```terminal
# once: clone your fork and name the original
git clone git@github.com:USERNAME/project.git
cd project
git remote add upstream git@github.com:ORIGINAL-OWNER/project.git

# whenever the original moves on
git fetch upstream
git switch main
git merge upstream/main
git push origin main
```

GitHub's #strong[Sync fork] button on your fork's page does the last four steps for `main`. Do your own work on branches, never on your fork's `main`, so that syncing is always a fast-forward.

== Protect `main` <sec:protect-main>

On a team repository, the owner can make the workflow a rule rather than a habit. Under the repository's #strong[Settings], #strong[Branches] (or #strong[Rules] #sym.arrow.r #strong[Rulesets]) add a rule for `main` that requires a pull request before merging, requires one or more approvals, and blocks force pushes. Direct pushes to `main` are then rejected, even from the owner, and every change is reviewed.

== Force-push safely <sec:force-with-lease>

Some commands in the next two chapters rewrite commits you have already pushed to #emph[your own] branch, for example tidying a pull request's commits before review. GitHub then rejects a normal push, because your branch and the remote one have diverged. Use:

```terminal
git push --force-with-lease
```

Plain `--force` overwrites the remote branch whatever it contains. `--force-with-lease` overwrites it only if it still points where your `origin/...` note says it does; if someone else pushed in the meantime, the push fails instead of deleting their work. Never force-push a branch other people build on, and never force-push `main`.

#summary[
  - `origin/main` is a note of where GitHub's `main` was; only `fetch`, `pull` and `push` move it.
  - `fetch` is always safe; `pull` is fetch plus merge or rebase; set `pull.rebase` once to choose.
  - A rejected push means pull first. Never `--force` a shared branch; use `--force-with-lease` on your own.
  - Work on branches, push them, and merge through reviewed pull requests; pick merge, squash or rebase deliberately.
  - Forks let you contribute without write access: push to `origin`, fetch from `upstream`, open a pull request.
  - Branch protection turns the workflow into a rule for `main`.
]

#questions[
  + `git status` says #emph[Your branch is up to date with 'origin/main'], but your teammate pushed five minutes ago. Is Git wrong? Which command would show their commit without changing your files?
  + What is the difference between `git fetch` and `git pull`?
  + Your push is rejected with #emph[fetch first]. What happened, and what are the next two commands?
  + You squash-merged a pull request on GitHub. Why does `git branch -d` on your local branch fail?
]

#answers[
  + Not wrong, just out of date: it compares with the note `origin/main`, which only moves when you talk to GitHub. `git fetch`, then `git log --oneline main..origin/main` or `git status`, shows it.
  + `fetch` downloads commits and moves the `origin/...` notes only. `pull` fetches and then merges (or rebases) into your current branch, changing your files.
  + Someone pushed commits you do not have. `git pull`, then `git push`.
  + The squash created a new commit on `main`; your branch's original commits are not part of `main`'s history, so Git cannot tell the work was merged. Confirm on GitHub, then use `git branch -D`.
]
