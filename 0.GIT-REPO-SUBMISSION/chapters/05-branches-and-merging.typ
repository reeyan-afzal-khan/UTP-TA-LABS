#import "/.shared/typst/utp.typ": *
#import "git-figures.typ": *
#unit("chapters", "05-branches-and-merging")

= Branches, HEAD and merging <ch:branches>

#chapterguide[#chapref(<ch:saving-work>): the four places, `git status`, `git add`, `git commit` and `git log`.][explain what a branch and `HEAD` really are; create, switch, rename and delete branches; predict whether a merge will fast-forward or make a merge commit; resolve a merge conflict by hand or in VS Code; read the branch graph; and get out of a detached `HEAD` without losing work.]

The to-do page needs a login page next. It will take a few sittings, and you want save points along the way. So far every commit has gone onto `main`, the version your teammate pulls and the version your lecturer marks. Commit a half-built login page there and the next person to pull gets a page that does not work. The staging area kept half-done work out of one snapshot; a #term[branch] keeps a whole feature's commits away from `main` until the feature is finished.

== A branch is a label <sec:branch-label>

To Git, a branch is not a copy of your files and not a folder. It is a #emph[label that points at one commit]. The branch's history is that commit and every commit behind it. When you commit on a branch, its label moves forward to the new commit; every other label stays where it was.

#term[`HEAD`] is a second kind of label: your #emph[you are here] pin. It normally points at a branch, and that branch points at a commit. `git log` shows the pair as `HEAD -> main`.

#utpfig([After `git switch -c feature/login` and one commit. `HEAD` follows you onto the new branch, so only `feature/login` moved forward. `main` still points at D, the version that works. Commits: A #emph[Add task list], B #emph[Add styles], C #emph[Add task form], D #emph[Add README], E #emph[Add login page].], label: <fig:branch-label>)[
  #canvas({
    let xs = (0, 1.5, 3.0, 4.5, 6.0)
    for (i, l) in ("A", "B", "C", "D").enumerate() {
      node((xs.at(i), 0), l, name: l, ..gcommit)
    }
    node((xs.at(4), 0), [E], name: "E", ..gnew)
    for (a, b) in (("A", "B"), ("B", "C"), ("C", "D"), ("D", "E")) { connect(a, b, ..gparent) }
    glabel("D", [main], "main", below: true)
    glabel("E", [feature/login], "feat")
    glabel("feat", [HEAD], "head", style: ghead, d: 0.32)
    node((-0.9, 0), [older], anchor: "east", ..gnote)
    connect((-0.85, 0), "A", ..gparentdim)
  })
]

You can see both labels for yourself. `HEAD` is a one-line file, and a branch resolves to a single commit hash:

```terminal
$ cat .git/HEAD
ref: refs/heads/feature/login
$ git rev-parse main
7d3b2f0e4a1c9b8d6f5e3a2c1b0d9e8f7a6b5c4d
```

This is why branches in Git are cheap: making one writes about forty characters, whatever the size of the project.

== Create, list and switch branches <sec:branch-commands>

#utptable[
  #tabularx(
    columns: (40%, 1fr),
    header: ([Command], [What it does]),
    [`git branch`], [Lists local branches; `*` marks the one `HEAD` is on],
    [`git branch -v`], [The same, with each branch's newest commit],
    [`git switch -c feature/login`], [Creates `feature/login` at the current commit and switches to it],
    [`git switch main`], [Moves `HEAD` to `main` and updates your files to match],
    [`git switch -`], [Switches back to the branch you were on before],
    [`git branch -m new-name`], [Renames the current branch],
    [`git branch -d feature/login`], [Deletes a branch whose work is already merged],
    [`git branch -D feature/login`], [Deletes a branch even if its work is #emph[not] merged. Its commits become hard to find (#chapref(<ch:undo>) shows how to recover them)],
  )
]

Older tutorials use `git checkout -b feature/login` and `git checkout main`. They do the same job; `switch` was added in Git 2.23 because `checkout` also restores files, which made it easy to run the wrong one. Prefix branch names by purpose (`feature/`, `fix/`, `lab03/`) and never use spaces.

=== Switching branches swaps your files

Commit the login page on `feature/login`, then switch to `main` and list the folder:

```terminal
git switch main
ls                       # login.html is gone
git switch feature/login
ls                       # login.html is back
```

Nothing was deleted. Switching branches makes your working folder match the newest commit of the branch you switch to, and `main` has no login page yet. The file is safe in its commit.

If you have uncommitted changes, Git carries them along when it can. When a change would be overwritten by the other branch's version of the same file, Git refuses rather than lose your work:

```terminal
error: Your local changes to the following files would be overwritten by checkout:
        index.html
Please commit your changes or stash them before you switch branches.
Aborting
```

Commit the change, or put it aside with `git stash` (#chapref(<ch:power-tools>)), then switch.

== Merge: fast-forward or merge commit <sec:merge>

`git merge` brings the commits of another branch into the branch you are on. Always switch to the #emph[receiving] branch first:

```terminal
$ git switch main
$ git merge feature/login
Updating 7d3b2f0..4c2a9e1
Fast-forward
 login.html | 4 ++++
 1 file changed, 4 insertions(+)
 create mode 100644 login.html
```

#emph[Fast-forward] means `main` had no new commits of its own since `feature/login` started, so there was nothing to combine: Git simply slid the `main` label forward. When both branches have new commits, Git must combine them, and it records the join as a #term[merge commit], a commit with #emph[two] parents.

#utpfig([The two outcomes of `git merge`. (a) Only the feature branch moved, so `main` slides forward: a fast-forward. (b) Both branches moved: Git makes merge commit M, whose first parent is G (where `main` was) and whose second parent is F (the branch merged in).], label: <fig:merge-kinds>)[
  #canvas({
    node((1.5, 2.15), [(a) Fast-forward], ..gtitle)
    node((0, 0), [D], name: "d1", ..gcommit)
    node((1.5, 0), [E], name: "e1", ..gcommit)
    node((3.0, 0), [F], name: "f1", ..gcommit)
    connect("d1", "e1", ..gparent)
    connect("e1", "f1", ..gparent)
    glabel("f1", [feature/login], "fl")
    glabel("d1", [main before], "mb", style: gremote, below: true)
    glabel("f1", [main after], "ma", below: true)

    node((8.65, 2.15), [(b) Merge commit], ..gtitle)
    node((6.4, 0), [D], name: "d2", ..gcommit)
    node((7.8, 0.6), [E], name: "e2", ..gcommit)
    node((9.2, 0.6), [F], name: "f2", ..gcommit)
    node((8.5, -0.6), [G], name: "g2", ..gcommit)
    node((10.9, 0), [M], name: "m2", ..gmerge)
    connect("d2", "e2", ..gparent)
    connect("e2", "f2", ..gparent)
    connect("d2", "g2", ..gparent)
    connect("f2", "m2", ..gparent)
    connect("g2", "m2", ..gparent)
    glabel("f2", [feature/title], "ft")
    glabel("g2", [main before], "mb2", style: gremote, below: true)
    glabel("m2", [main after], "ma2", below: true)
  })
]

Two options change this behaviour:

- `git merge --no-ff feature/login` always makes a merge commit, even when a fast-forward is possible. The history then shows clearly that a group of commits arrived together as one feature. GitHub's default #emph[Merge pull request] button does this (#chapref(<ch:collaboration>)).
- `git merge --ff-only feature/login` refuses to do anything except a fast-forward. Use it when you expect a fast-forward and want Git to stop if your expectation is wrong.

Once a feature is merged, delete its branch with `git branch -d feature/login`. The commits stay in `main`'s history; only the label goes.

== Merge conflicts <sec:conflicts>

Git combines changes to #emph[different] lines, or different files, on its own. When both branches change the #emph[same] lines, Git will not guess which version you want. It stops and asks: that is a #term[merge conflict]. Conflicts are a normal part of working with other people, not an error.

Here is how one happens. Your teammate, working directly on `main`, renames the heading to `Team To-Do`, commits and pushes. Meanwhile, on `feature/title`, you rename the same heading to `My Tasks` and colour it teal in `style.css`. You pull your teammate's work into `main`, then merge your branch:

```terminal
$ git merge feature/title
Auto-merging index.html
CONFLICT (content): Merge conflict in index.html
Automatic merge failed; fix conflicts and then commit the result.
```

=== Find what needs fixing

```terminal
$ git status
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Changes to be committed:
        modified:   style.css

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   index.html
```

Only you changed `style.css`, so Git merged it and staged it already. `index.html` is #emph[both modified]: that file needs you. Inside it, Git has written both versions between #term[conflict markers]:

```html
<<<<<<< HEAD
<h1>Team To-Do</h1>
=======
<h1>My Tasks</h1>
>>>>>>> feature/title
<ul id="tasks"></ul>
```

Between `<<<<<<< HEAD` and `=======` is the version on the branch you are on (`main`, which now has your teammate's rename). Between `=======` and `>>>>>>> feature/title` is the version coming in. Everything outside the markers merged without trouble.

=== Resolve, then add and commit

+ Edit the file into the version you want. Keep one side, keep the other, or write something new, such as `<h1>Team Tasks</h1>`.
+ Delete all three marker lines.
+ `git add index.html` to tell Git this file is resolved.
+ `git commit` to make the merge commit. Git suggests the message `Merge branch 'feature/title'`; save and close the editor to accept it.

If you would rather not merge after all, `git merge --abort` puts everything back as it was before `git merge`.

#tip[
  VS Code highlights each conflict and offers #strong[Accept Current Change] (the `HEAD` side), #strong[Accept Incoming Change], #strong[Accept Both Changes] and #strong[Compare Changes] above it. For larger conflicts, #strong[Resolve in Merge Editor] opens a three-column view: incoming, current, and the result you are building.
]

#warning[
  A file still containing `<<<<<<<` or `>>>>>>>` will be committed exactly as it is if you `git add` it, and the page or program will break. Before committing a merge, run `git diff --check`, which reports leftover conflict markers, or search with `git grep -n "<<<<<<<"`.
]

=== Make conflicts easier to read

By default Git shows only the two sides. Ask it to also show the #emph[original] line, the one both sides started from, and most conflicts become obvious:

```terminal
git config --global merge.conflictStyle zdiff3
```

```html
<<<<<<< HEAD
<h1>Team To-Do</h1>
||||||| 4c2a9e1
<h1>To-Do</h1>
=======
<h1>My Tasks</h1>
>>>>>>> feature/title
```

Now you can see that both of you edited `To-Do`: neither side is an accident. When you know one side should win for an entire file, `git checkout --ours index.html` or `git checkout --theirs index.html` takes that side wholesale. During a merge, #emph[ours] is the branch you are on and #emph[theirs] is the branch being merged in.

== Read the branch graph <sec:graph>

`git log --oneline --graph --all` draws every branch to the left of the commits. Read it from the bottom up:

```terminal
$ git log --oneline --graph --all
*   1a7c4e9 (HEAD -> main) Merge branch 'feature/title'
|\
| * 6f0b8d5 (feature/title) Rename heading to My Tasks
* | 3e8a9c2 (origin/main) Rename heading to Team To-Do
|/
* 4c2a9e1 (feature/login) Add login page
* 7d3b2f0 Add README
* 9c1e2f4 Add task form
```

Each `*` is a commit. After #emph[Add login page] the line splits in two, `main` on the left and `feature/title` on the right, and they join at the merge commit. A merge commit's parents have their own names: `HEAD^1` (or `HEAD^`) is the first parent, where `main` was; `HEAD^2` is the second, the branch that was merged in. `git show HEAD` on a merge commit prints both on a `Merge:` line.

#note[
  `~` and `^` both step back through history. `HEAD~2` follows first parents two steps back. `HEAD^2` picks the #emph[second parent] of a merge. On ordinary commits, which have one parent, `HEAD~1` and `HEAD^` mean the same thing.
]

== Detached `HEAD` <sec:detached-head>

You can point `HEAD` straight at a commit instead of at a branch, for example to look at an old version of the project:

```terminal
$ git switch --detach 3741b16
HEAD is now at 3741b16 Add task list
```

(`git checkout 3741b16` does the same and prints a longer warning about #emph[detached HEAD state].) Your files now match that old commit. Look around, run the code, even commit. But commits made here belong to #emph[no branch], so once you switch away nothing points at them and they are easy to lose.

- To leave without keeping anything: `git switch main`.
- To keep what you made here: `git switch -c experiment` creates a branch at the current commit, and you are attached again.
- If you already switched away and lost the commits, `git reflog` still remembers them (#chapref(<ch:undo>)).

#summary[
  - A branch is a movable label on a commit; `HEAD` points at the branch you are on.
  - `git switch -c` creates and switches; `git switch` changes branch and swaps your files to match.
  - A merge fast-forwards when only one side moved; otherwise it makes a merge commit with two parents.
  - A conflict is Git asking which version you want: edit the file, remove the markers, `git add`, then `git commit`, or back out with `git merge --abort`.
  - `merge.conflictStyle zdiff3` shows the original line, which makes most conflicts easy to judge.
  - `git log --oneline --graph --all` draws the history; `HEAD^2` is a merge's second parent.
  - In detached `HEAD`, create a branch before you leave if you want to keep your commits.
]

#exercises[
  Recreate the conflict in this chapter in your `todo-app` repository, alone. Make branch `feature/title` from `main` and change the heading there; switch back to `main` and change the same line differently; commit both. Then:

  + Predict the output of `git merge feature/title`, then run it.
  + Abort with `git merge --abort` and confirm with `git status` that nothing changed.
  + Set `merge.conflictStyle` to `zdiff3`, merge again, resolve the conflict, and finish the merge.
  + Draw the result with `git log --oneline --graph --all` and name both parents of the merge commit.
]

#questions[
  + You are on `main` and run `git switch -c fix/typo`, then make two commits. Which labels moved, and where does `main` point?
  + `git merge feature/x` prints #emph[Fast-forward]. Was a new commit created?
  + During a merge conflict, which side of the markers holds the version from the branch you are on?
  + You checked out an old commit, fixed a bug there and committed. How do you keep that fix?
]

#answers[
  + `fix/typo` (and `HEAD` with it) moved two commits forward. `main` did not move: it still points at the commit where the branch was created.
  + No. `main` only slid forward to the commit `feature/x` already pointed at.
  + The top part, between `<<<<<<< HEAD` and `=======`.
  + Create a branch where you are, with `git switch -c fix/old-bug`, then merge it like any other branch.
]
