#import "/.shared/typst/utp.typ": *
#import "git-figures.typ": *
#unit("chapters", "07-undoing-changes")

= Undoing changes safely <ch:undo>

#chapterguide[#chapsref(<ch:saving-work>, <ch:collaboration>): the four places, branches and `HEAD`, and the difference between a commit on your computer and a commit on GitHub.][choose the right undo for any mistake by asking where it is and whether it has been pushed; discard or unstage changes with `git restore`; repair the last commit with `--amend`; move a branch back with the three modes of `git reset`; undo a pushed commit with `git revert`; recover #emph[lost] commits and deleted branches with `git reflog`; and clean out untracked files without deleting the wrong ones.]

Everyone commits the wrong file, writes the wrong message, or deletes a branch they still needed. Git can undo almost all of it, and most beginners lose work not because Git could not help but because they reached for the wrong undo command, or for `rm -rf` and a fresh clone. This chapter turns undoing into two questions and a table.

#note[
  Before undoing anything, answer two questions.

  + #strong[Where is the mistake?] In the working folder, the staging area, a commit, or on GitHub (#figref(<fig:four-places>))?
  + #strong[Has it been pushed?] If nobody else can have the commit yet, you may rewrite it. If it is on a shared branch, add a new commit that reverses it instead.
]

== Choose the right undo <sec:undo-table>

#utptable[
  #tabularx(
    columns: (33%, 38%, 1fr),
    header: ([Your situation], [Command], [Safe after push?]),
    [Edited a file and want the last committed version back], [`git restore index.html`], [Yes (nothing was committed). The edits are lost for good],
    [Staged a file by mistake], [`git restore --staged index.html`], [Yes; the edits stay in your folder],
    [Last commit has a wrong message or is missing a file], [`git commit --amend`], [No: it replaces the commit],
    [Undo the last commit, keep its changes], [`git reset --soft HEAD~1`], [No],
    [Throw away the last commit and its changes], [`git reset --hard HEAD~1`], [No],
    [Undo a commit that is already on GitHub], [`git revert <hash>`], [Yes: it adds a new commit],
    [Get back a commit or branch you lost], [`git reflog`, then `git branch` or `git reset`], [Yes],
    [Bring back one file from an older commit], [`git restore --source=<hash> index.html`], [Yes; it only changes your folder],
    [Delete untracked clutter], [`git clean -n`, then `git clean -f`], [Yes. Deleted files cannot be recovered],
  )
]

== Discard and unstage with `git restore` <sec:restore>

`git restore` copies a version of a file over another place. Without options it overwrites the #emph[working folder] copy with the staged version (which is the last committed version unless you staged something):

```terminal
git restore index.html          # throw away my edits to index.html
git restore .                   # throw away every unstaged edit
```

With `--staged` it takes a file off the tray, resetting the staging area to the last commit and leaving your edits in place:

```terminal
git restore --staged .env       # unstage; the file and its contents stay
```

And with `--source` it brings back a file as it was in any commit, without moving any branch:

```terminal
git log --oneline -- index.html             # find the version you want
git restore --source=9c1e2f4 index.html     # restore that version into the folder
```

#warning[
  `git restore <file>`, `git reset --hard` and `git clean` destroy #emph[uncommitted] work, and uncommitted work was never saved anywhere Git can recover it from. Before running them, read `git status` and `git diff` once more. When in doubt, `git stash` (#chapref(<ch:power-tools>)) instead: it keeps a copy.
]

Older tutorials use `git checkout -- index.html` and `git reset HEAD index.html` for these jobs; they still work, and `git status` itself now suggests `git restore`.

== Repair the last commit with `--amend` <sec:amend>

You committed, then noticed a typo in the message or a file you forgot to stage. Rather than adding a second commit called #emph[fix previous commit], replace the last one:

```terminal
git commit --amend -m "Add task form with validation"   # new message

git add style.css
git commit --amend --no-edit                            # add a forgotten file, keep the message
```

`--amend` does not edit the old commit; commits never change. It makes a #emph[new] commit with a new hash and moves the branch to it. That is harmless if the old commit exists only on your computer. If you had already pushed it, the branch on GitHub and yours have now diverged, and you would need `git push --force-with-lease` (#secref(<sec:force-with-lease>)): fine for your own feature branch, never for a shared one.

== Move a branch back with `git reset` <sec:reset>

`git reset <commit>` moves the current branch, and `HEAD` with it, back to an earlier commit. The commits after it are no longer on the branch. All three modes move the branch; what happens to the #emph[changes] those commits made depends on the mode:

#utptable[
  #tabularx(
    columns: (29%, 23%, 19%, 1fr),
    header: ([Command], [Staging area], [Working folder], [Use it to]),
    [`git reset --soft HEAD~1`], [Unchanged: the commit's changes stay staged], [Unchanged], [Redo the last commit differently, or combine several commits into one],
    [`git reset --mixed HEAD~1` (the default)], [Reset: changes become unstaged], [Unchanged], [Undo the commit and re-stage only some of it],
    [`git reset --hard HEAD~1`], [Reset], [Reset: changes are #emph[gone]], [Throw the commit and its work away entirely],
  )
]

#utpfig([After `git reset --hard HEAD~2` on `main`. The branch label moves back to B. Commits C and D still exist, but no branch points at them any more; `git reflog` still knows their hashes for weeks, so the reset can be undone.], label: <fig:reset>)[
  #canvas({
    node((0, 0), [A], name: "A", ..gcommit)
    node((1.5, 0), [B], name: "B", ..gcommit)
    node((3.0, 0), [C], name: "C", ..gdim)
    node((4.5, 0), [D], name: "D", ..gdim)
    connect("A", "B", ..gparent)
    connect("B", "C", ..gparentdim)
    connect("C", "D", ..gparentdim)
    glabel("B", [main], "main")
    glabel("main", [HEAD], "head", style: ghead, d: 0.32)
    glabel("D", [main before], "old", style: gremote)
    node((3.75, -0.85), [still reachable through `git reflog`], ..gnote)
  })
]

Two more uses come up often:

```terminal
git reset --hard origin/main    # make my main exactly match GitHub's, dropping my local commits
git reset --hard ORIG_HEAD      # undo the reset, merge or rebase I just ran
```

Git saves the commit you were on in `ORIG_HEAD` before every reset, merge and rebase, so the second line is the quickest undo of an undo.

#warning[
  `reset` rewrites the branch. If the commits you remove were already pushed, GitHub still has them, the next `git pull` brings them straight back, and anyone who based work on them now has a history that disagrees with yours. For pushed commits on a shared branch, use `git revert`.
]

== Undo a pushed commit with `git revert` <sec:revert>

`git revert` does not remove a commit. It adds a #emph[new] commit that applies the exact opposite change, so history only moves forward and everyone can pull it normally:

```terminal
$ git revert 5e2d9a3
[main 2b9f7c1] Revert "Add dark theme"
 1 file changed, 3 deletions(-)
$ git push
```

Git opens the editor with the message `Revert "Add dark theme"` and a line `This reverts commit 5e2d9a3...`; add a sentence saying why. If later commits changed the same lines, the revert can conflict: resolve as in #secref(<sec:conflicts>), `git add`, then `git revert --continue`, or give up with `git revert --abort`.

To revert a #emph[merge] commit, Git needs to know which side to keep. `-m 1` keeps the first parent (the branch that received the merge, usually `main`) and removes everything the merged branch brought in:

```terminal
git revert -m 1 1a7c4e9
```

== Recover anything with `git reflog` <sec:reflog>

Every time `HEAD` moves (commit, switch, merge, reset, rebase, amend), Git writes a line in the #term[reflog], a private diary of where you have been. Commits that no branch points to are not deleted straight away; the reflog keeps them reachable, by default for 30 days for such orphaned commits and 90 days for the rest.

```terminal
$ git reflog
7d3b2f0 (HEAD -> main) HEAD@{0}: reset: moving to HEAD~2
4c2a9e1 HEAD@{1}: commit: Add delete button
9a8b7c6 HEAD@{2}: commit: Add task counter
7d3b2f0 HEAD@{3}: pull: Fast-forward
```

Read it from the top: the newest move is first. `HEAD@{1}` was the state just before the reset, with both commits. Bring them back by moving the branch there, or by putting a new branch on them:

```terminal
git reset --hard 4c2a9e1        # main gets its two commits back
git branch rescued 4c2a9e1      # or: keep main as it is, and label the lost work
```

A deleted branch is recovered the same way. `git branch -D` even prints the hash you need: `Deleted branch feature/login (was 4c2a9e1).` If that message has scrolled away, search the reflog for the last time you were on the branch (`checkout: moving from feature/login to main`) and recreate it with `git branch feature/login <hash>`.

#note[
  The reflog is local to your computer and is never pushed. It cannot recover changes that were never committed, which is one more reason to commit small and often: a commit, even a messy one you later squash, is a save point the reflog can find.
]

== Remove untracked files with `git clean` <sec:clean>

Build outputs, temporary files and abandoned experiments pile up as untracked files. `git clean` deletes them; it is the only common Git command that removes files Git has never saved, so it has a dry run:

```terminal
git clean -n          # list what would be deleted; deletes nothing
git clean -f          # delete untracked files
git clean -fd         # ... and untracked folders
git clean -fdx        # ... and ignored files too: .venv/, .env, caches
```

#warning[
  `-x` also deletes files listed in `.gitignore`. That includes your virtual environment, your `.env` file with real keys, and downloaded datasets. Always run `git clean -n` with the same options first, and read the list.
]

#summary[
  - Ask where the mistake is and whether it was pushed; the table in #secref(<sec:undo-table>) gives the command.
  - `git restore` discards working-folder edits; `--staged` unstages; `--source` brings back an old version of a file.
  - `--amend` replaces the last commit; `reset --soft`, `--mixed` and `--hard` move the branch back and differ in what they do to your changes.
  - `git revert` undoes a pushed commit by adding its opposite; `-m 1` reverts a merge.
  - `git reflog` remembers every position of `HEAD`, so committed work is almost never truly lost.
  - Uncommitted work can be lost: read `git status` before `restore`, `reset --hard` or `clean`, and dry-run `git clean -n` first.
]

#exercises[
  Run a disaster drill in your `todo-app` repository.

  + Make three small commits on `main`, then run `git reset --hard HEAD~3`. Confirm with `git log --oneline` that they are gone.
  + Find them with `git reflog` and restore `main` to the newest of them.
  + Create a branch `feature/drill`, commit on it, switch back to `main`, and delete it with `git branch -D`. Recreate it from the hash Git printed.
  + Commit a change, then undo it with `git revert`. Compare `git log --oneline` after the revert with what `reset` did in step 1.
]

#questions[
  + You ran `git add .` and staged `.env` by accident. You have not committed. Which command fixes it without losing the file?
  + You pushed a commit to `main` that breaks the page, and your teammate has already pulled it. `reset` or `revert`? Why?
  + What is the difference between `git reset --soft HEAD~1` and `git reset --hard HEAD~1`?
  + Yesterday you ran `git reset --hard HEAD~4` and now need those commits. Is it too late?
]

#answers[
  + `git restore --staged .env`, then add `.env` to `.gitignore`.
  + `revert`. It adds a new commit that undoes the change, so your teammate's history and GitHub's stay consistent; `reset` would rewrite a commit they already have.
  + Both move the branch back one commit. `--soft` keeps that commit's changes staged; `--hard` deletes them from the staging area and the working folder.
  + No. `git reflog` lists the commit you were on before the reset; `git reset --hard` to that hash, or `git branch rescued <hash>`.
]
