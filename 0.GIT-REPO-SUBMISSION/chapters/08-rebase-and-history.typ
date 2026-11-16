#import "/.shared/typst/utp.typ": *
#import "git-figures.typ": *
#unit("chapters", "08-rebase-and-history")

= Rebasing and rewriting history <ch:rebase>

#chapterguide[#chapref(<ch:branches>) (merging and conflicts), #chapref(<ch:collaboration>) (pushing branches and `--force-with-lease`) and #chapref(<ch:undo>) (`reset` and `reflog`).][explain what `git rebase` does to commits and why their hashes change; choose between merging and rebasing; rebase a feature branch onto `main` and resolve conflicts along the way; tidy a branch with interactive rebase (reword, squash, fixup, reorder, drop, split); use `--fixup` with `--autosquash`; copy single commits with `git cherry-pick`; and undo a rebase that went wrong.]

A merge records history as it happened, including every #emph[WIP] commit and every join. Sometimes that is exactly what you want. Other times, before asking for a review, you want the branch to read like a clear story: a few well-named commits, starting from today's `main`. #term[Rebasing] lets you rewrite your own commits into that shape. It is the most powerful command in this book and the one most worth using carefully.

== What rebase does <sec:what-rebase-does>

`git rebase main`, run on a feature branch, takes the commits that are on the feature branch but not on `main`, and #emph[replays] them one at a time on top of `main`'s newest commit. Each replayed commit has the same change and message as the original but a different parent, so it is a new commit with a new hash. The branch label then moves to the last replayed commit.

#utpfig([Rebasing `feature/dark-theme` onto `main`. (a) The branch started at B, and `main` has since gained E. (b) After `git rebase main`, C and D are replayed as new commits C′ and D′ on top of E. The originals are left behind, unreferenced; the history is a single straight line.], label: <fig:rebase>)[
  #canvas({
    node((2.1, 2.15), [(a) Before], ..gtitle)
    node((0, 0), [A], name: "a1", ..gcommit)
    node((1.4, 0), [B], name: "b1", ..gcommit)
    node((2.8, -0.6), [E], name: "e1", ..gcommit)
    node((2.8, 0.6), [C], name: "c1", ..gcommit)
    node((4.2, 0.6), [D], name: "d1", ..gcommit)
    connect("a1", "b1", ..gparent)
    connect("b1", "e1", ..gparent)
    connect("b1", "c1", ..gparent)
    connect("c1", "d1", ..gparent)
    glabel("d1", [feature/dark-theme], "f1")
    node(right-of("e1", 0.25), [main], name: "m1", ..gbranch)
    connect("m1", "e1", ..gptr)

    node((9.3, 2.15), [(b) After `git rebase main`], ..gtitle)
    node((6.5, 0), [A], name: "a2", ..gcommit)
    node((7.9, 0), [B], name: "b2", ..gcommit)
    node((9.3, 0), [E], name: "e2", ..gcommit)
    node((10.7, 0), [C′], name: "c2", ..gnew)
    node((12.1, 0), [D′], name: "d2", ..gnew)
    node((9.3, 1.05), [C], name: "c0", ..gdim)
    node((10.7, 1.05), [D], name: "d0", ..gdim)
    connect("a2", "b2", ..gparent)
    connect("b2", "e2", ..gparent)
    connect("e2", "c2", ..gparent)
    connect("c2", "d2", ..gparent)
    connect("b2", "c0", ..gparentdim)
    connect("c0", "d0", ..gparentdim)
    glabel("e2", [main], "m2", below: true)
    glabel("d2", [feature/dark-theme], "f2", below: true)
  })
]

```terminal
$ git switch feature/dark-theme
$ git rebase main
Successfully rebased and updated refs/heads/feature/dark-theme.
```

Compare this with merging `main` into the branch (#secref(<sec:pull-requests>)), which would have left C and D alone and added a merge commit joining D and E. Both give a branch that contains E; they differ in the history they leave.

#utptable[
  #tabularx(
    columns: (24%, 1fr, 1fr),
    styles: (navy-bold,),
    header: ([], [Merge], [Rebase]),
    [History], [True record of what happened, with joins], [A straight line, as if you had started from today's `main`],
    [Existing commits], [Never changed], [Replaced by new commits with new hashes],
    [Conflicts], [Resolved once, in the merge commit], [Resolved commit by commit, possibly several times],
    [Safe on shared branches], [Yes], [No: only on commits nobody else has],
    [Undo], [`git reset --hard ORIG_HEAD` or `git revert -m 1`], [`git reset --hard ORIG_HEAD` or the reflog],
  )
]

#warning[
  #strong[The golden rule of rebasing: never rebase commits that other people have.] Rebasing replaces commits. If your teammate has the originals, their history and yours now disagree, and the next pull duplicates every commit or ends in a tangle of conflicts. Rebase only your own branches: local commits, or a feature branch that only you push to. After rebasing a branch you had already pushed, update it with `git push --force-with-lease` (#secref(<sec:force-with-lease>)).
]

=== Pull with rebase

The divergence in #figref(<fig:diverged>) can be settled by rebasing instead of merging: your local commit D is replayed on top of your teammate's E, and no merge commit is made.

```terminal
git pull --rebase                         # once
git config --global pull.rebase true      # or make it the default
git config --global rebase.autoStash true # stash uncommitted edits around the rebase
```

This is safe even on `main`, because the only commits being replaced are your own, which nobody else has yet.

== Conflicts during a rebase <sec:rebase-conflicts>

Because rebase replays commits one at a time, it can stop at any of them:

```terminal
$ git rebase main
Auto-merging style.css
CONFLICT (content): Merge conflict in style.css
error: could not apply 5c8e1d2... Add dark theme
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
```

Resolve the file exactly as for a merge conflict, then:

```terminal
git add style.css
git rebase --continue      # replay the next commit
```

`git rebase --abort` returns everything to how it was before you started. `git rebase --skip` drops the commit that conflicted, which is only right if that change is no longer needed.

#note[
  During a rebase, #emph[ours] and #emph[theirs] swap meaning. Git is replaying your commits onto `main`, so `HEAD` (#emph[ours], the top of the conflict markers, `git checkout --ours`) is `main` plus the commits already replayed, and #emph[theirs] is your commit being applied. Read the labels on the markers rather than trusting the words.
]

If the same conflict comes back on several commits, or every time you rebase a long-running branch, let Git remember your resolution and reapply it automatically:

```terminal
git config --global rerere.enabled true    # reuse recorded resolution
```

== Tidy a branch with interactive rebase <sec:interactive-rebase>

`git rebase -i` (interactive) opens a to-do list of the commits it is about to replay and lets you edit it first. Before opening a pull request, a branch often looks like this:

```terminal
$ git log --oneline main..
0f1e2d3 Add delete button
9a8b7c6 WIP
5d6e7f8 Fix typo in task form
1a2b3c4 Add task form
```

`main..` means #emph[commits on this branch that are not on `main`] (#secref(<sec:ranges>)). Rebase those four onto the same base:

```terminal
git rebase -i main          # or: git rebase -i HEAD~4
```

The editor opens with the #emph[oldest commit at the top], the reverse of `git log`:

```text
pick 1a2b3c4 Add task form
pick 5d6e7f8 Fix typo in task form
pick 9a8b7c6 WIP
pick 0f1e2d3 Add delete button

# Rebase 7d3b2f0..0f1e2d3 onto 7d3b2f0 (4 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup [-C | -c] <commit> = like "squash" but keep only the previous
#                    commit's log message, unless -C is used ...
# d, drop <commit> = remove commit
...
```

Change the first word of each line, or reorder the lines, then save and close. The typo fix belongs inside #emph[Add task form], and the #emph[WIP] commit was really the start of the delete button:

```text
pick 1a2b3c4 Add task form
fixup 5d6e7f8 Fix typo in task form
pick 9a8b7c6 WIP
squash 0f1e2d3 Add delete button
```

Git replays the commits, folds the typo fix silently into #emph[Add task form], and opens the editor once more to write a single message for the #emph[WIP] and #emph[Add delete button] pair. The branch now has two clean commits.

#utptable[
  #tabularx(
    columns: (17%, 1fr),
    styles: (mono-cell,),
    header: ([Word], [Effect on that commit]),
    [pick], [Keep it as it is],
    [reword], [Keep the change; stop to edit its message],
    [edit], [Stop after applying it, so you can amend it or split it],
    [squash], [Combine it into the commit above it and edit the combined message],
    [fixup], [Combine it into the commit above it and keep only the commit above's message],
    [drop], [Remove the commit and its change (deleting the line does the same)],
    [(move line)], [Reorder: commits are replayed in the order of the lines],
  )
]

=== Split a commit in two

Mark the commit `edit`. When the rebase stops there, undo the commit but keep its changes, then commit them in pieces:

```terminal
git reset HEAD~1                   # the commit's changes are now unstaged
git add index.html
git commit -m "Add delete button markup"
git add app.js
git commit -m "Delete a task when its button is clicked"
git rebase --continue
```

=== Prepare fixups as you go: `--fixup` and `--autosquash`

When you notice a mistake in an earlier commit of your branch, commit the correction aimed at that commit:

```terminal
git add index.html
git commit --fixup=1a2b3c4         # message becomes "fixup! Add task form"
git rebase -i --autosquash main    # the fixup line is already moved and marked
```

With `git config --global rebase.autoSquash true`, every interactive rebase does this automatically.

#exercises[
  On a new branch in `todo-app`, make five commits: two real features, a #emph[typo] commit fixing the first feature, a #emph[WIP] commit and one with a bad message. Use one interactive rebase to finish with exactly two well-named commits. Check the result with `git log --oneline main..`, then confirm with `git diff ORIG_HEAD` that the files are identical to before the rebase: only the history changed.
]

== Copy single commits with `git cherry-pick` <sec:cherry-pick>

Sometimes you need one commit from another branch, not the whole branch: a bug fix made on `feature/login` that `main` needs today. `git cherry-pick` replays that one commit on top of the branch you are on:

```terminal
git switch main
git cherry-pick -x 6b1f0e3
```

The new commit has the same change and message as `6b1f0e3` but a new hash. `-x` adds the line `(cherry picked from commit 6b1f0e3...)` to the message, so anyone can trace where it came from. You can pick several commits at once (`git cherry-pick A B C`) or a range (`git cherry-pick A^..C`, from A to C inclusive). Conflicts work as in a rebase: resolve, `git add`, then `git cherry-pick --continue`, or `--abort`.

Use cherry-pick for occasional copies. If you find yourself cherry-picking many commits between the same branches, merge or rebase instead; repeated copies of the same change make later merges harder to read.

== Undo a rebase <sec:undo-rebase>

Rebase moves the branch, so the tools of #chapref(<ch:undo>) apply. Immediately afterwards, `ORIG_HEAD` holds the branch's old position:

```terminal
git reset --hard ORIG_HEAD
```

Later, find the moment before the rebase in the reflog, where it is marked `rebase (start)`, and reset to the entry just below it:

```terminal
$ git reflog
3c9d0e1 (HEAD -> feature/dark-theme) HEAD@{0}: rebase (finish): returning to refs/heads/feature/dark-theme
3c9d0e1 HEAD@{1}: rebase (pick): Add dark theme
7f2a1b4 HEAD@{2}: rebase (start): checkout main
5c8e1d2 HEAD@{3}: commit: Add dark theme
$ git reset --hard HEAD@{3}
```

#summary[
  - `git rebase main` replays your branch's commits on top of `main`; the replayed commits are new commits with new hashes.
  - Merge keeps history as it happened; rebase makes it linear. Never rebase commits other people have.
  - Resolve rebase conflicts commit by commit: fix, `git add`, `git rebase --continue` (or `--abort`).
  - `git rebase -i` rewords, squashes, fixes up, reorders, drops and splits commits; `--fixup` plus `--autosquash` automates the common case.
  - `git cherry-pick -x` copies single commits between branches.
  - `ORIG_HEAD` and the reflog undo any rebase.
]

#questions[
  + After `git rebase main`, does your branch contain the same commits it did before? Explain using hashes.
  + Your teammate has pulled your branch `feature/login`. Should you rebase it to tidy the commits?
  + In the interactive rebase to-do list, which line is the oldest commit?
  + What is the difference between `squash` and `fixup`?
  + When would you cherry-pick rather than merge?
]

#answers[
  + The same #emph[changes] and messages, but not the same commits: each was replayed with a new parent, so each has a new hash.
  + No. They have the original commits; rewriting them breaks their history. Tidy only before others have your commits, or agree with them first.
  + The top line. The list runs oldest to newest, the reverse of `git log`.
  + Both fold a commit into the one above it. `squash` lets you edit the combined message; `fixup` keeps the earlier commit's message and discards the folded one's.
  + When you need one or two specific commits, such as an urgent fix, and not the rest of the branch.
]
