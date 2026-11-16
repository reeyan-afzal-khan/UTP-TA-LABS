#import "/.shared/typst/utp.typ": *
#import "git-figures.typ": *
#unit("chapters", "10-power-tools")

= Stashes, tags and other power tools <ch:power-tools>

#chapterguide[#chapsref(<ch:saving-work>, <ch:undo>): the everyday loop, branches, remotes and the undo commands.][set work aside with `git stash` and bring it back; mark releases and submissions with tags and publish them on GitHub; work on two branches at once with worktrees; shorten long commands with aliases; set up a global configuration that avoids the common traps; run checks automatically before every commit with hooks; and recognise when submodules and shallow clones are the right tool.]

This chapter collects the tools that turn Git from something you get through into something that works for you. None of them is needed to submit a lab; each saves real time once projects grow and deadlines overlap.

== Set work aside with `git stash` <sec:stash>

You are halfway through the login form on `feature/login` when your teammate reports that the live page crashes. The form is not ready to commit, but you need a clean `main` now. A #term[stash] is a shelf beside the four places: it saves your uncommitted changes, staged and unstaged, and returns your working folder to the last commit.

```terminal
$ git stash push -m "half-done login form"
Saved working directory and index state On feature/login: half-done login form
$ git switch main
# ... fix the crash, commit, push ...
$ git switch feature/login
$ git stash pop
```

`pop` re-applies the newest stash and removes it from the shelf. If re-applying conflicts with changes made since, Git keeps the stash so nothing is lost; resolve the conflict, then `git stash drop`.

#utptable[
  #tabularx(
    columns: (38%, 1fr),
    header: ([Command], [What it does]),
    [`git stash push -m "note"`], [Shelve tracked changes with a description (plain `git stash` works too)],
    [`git stash push -u`], [Also shelve #emph[untracked] files, such as a new file not yet added],
    [`git stash list`], [List the shelf; `stash@{0}` is the newest],
    [`git stash show -p stash@{1}`], [Show the diff stored in a stash],
    [`git stash apply stash@{1}`], [Re-apply a stash but keep it on the shelf],
    [`git stash pop`], [Re-apply the newest stash and remove it],
    [`git stash drop stash@{1}`], [Delete one stash],
    [`git stash branch feature/x`], [Create a branch where the stash was made and apply it there; avoids conflicts with later work],
  )
]

#warning[
  Stashes are easy to forget and are not pushed to GitHub. Use them for minutes or hours, not for days. Anything you want to keep longer belongs on a branch as a commit, even one named #emph[WIP] that you will squash later (#secref(<sec:interactive-rebase>)).
]

== Mark versions with tags <sec:tags>

A #term[tag] is a label on a commit that, unlike a branch, never moves. Tags mark releases (`v1.0.0`) and, in coursework, exactly what you submitted (`lab03-submitted`), so you and your lecturer can always find that version again even after later commits.

Git has two kinds. A #emph[lightweight] tag is just a name. An #emph[annotated] tag is a full object with its own author, date and message, and can be signed (#secref(<sec:signing>)); use annotated tags for anything you share.

```terminal
git tag -a v1.0.0 -m "First public version of the to-do page"   # tag the current commit
git tag -a lab03-submitted 9c1e2f4 -m "Lab 3 as submitted"      # tag an earlier commit
git tag -l "v1.*"                                               # list matching tags
git show v1.0.0                                                 # the tag's message and its commit
```

Tags are #emph[not] pushed by `git push`. Push them explicitly:

```terminal
git push origin v1.0.0            # one tag
git push --follow-tags            # with your commits, push the annotated tags that point at them
```

Delete a wrong tag locally with `git tag -d v1.0.0` and on GitHub with `git push origin --delete v1.0.0`. Avoid moving a tag others may already have; create a new version number instead.

Release numbers usually follow #term[semantic versioning], `MAJOR.MINOR.PATCH`: raise PATCH for bug fixes, MINOR for new features that keep everything else working, and MAJOR for changes that break existing use. `git describe --tags` names any commit relative to the nearest tag, for example `v1.0.0-3-g4c2a9e1`: three commits after `v1.0.0`, at commit `4c2a9e1`. Projects often print it as their version string.

On GitHub, a #strong[release] is a tag with release notes and downloadable files. On the repository page choose #strong[Releases] #sym.arrow.r #strong[Draft a new release], pick or create the tag, and select #strong[Generate release notes] to list the pull requests merged since the previous release.

== Two branches at once with `git worktree` <sec:worktree>

Stashing is awkward when the interruption is long: a review of your teammate's branch, or a model training for an hour on one branch while you work on another. A #term[worktree] is a second working folder attached to the same repository, with its own branch checked out:

```terminal
git worktree add -b fix/crash ../todo-app-hotfix main   # new folder, new branch from main
cd ../todo-app-hotfix                                   # work, commit and push here as usual
cd ../todo-app
git worktree list
git worktree remove ../todo-app-hotfix                  # when you are finished
```

Both folders share one `.git`, so commits made in one are immediately visible to the other, without pushing. Git allows each branch to be checked out in only one worktree at a time.

== Shorten commands with aliases <sec:aliases>

An #term[alias] is your own Git command:

```terminal
git config --global alias.st "status -sb"
git config --global alias.lg "log --oneline --graph --all --decorate"
git config --global alias.last "log -1 --stat"
git config --global alias.unstage "restore --staged"
git config --global alias.undo "reset --soft HEAD~1"
```

Now `git lg` draws the whole graph and `git undo` takes back the last commit while keeping its changes. `status -sb` is a two-column short status: the first column is the staging area, the second the working folder, so `M ` is staged, ` M` is not, and `??` is untracked.

== A global configuration that avoids common traps <sec:config>

Every setting below has appeared earlier in the book. Together they make Git's defaults friendlier; run the ones you want once per computer.

#utptable[
  #tabularx(
    columns: (44%, 1fr),
    header: ([Setting], [Effect]),
    [`init.defaultBranch main`], [New repositories start on `main` (#chapref(<ch:git-ssh-setup>))],
    [`core.editor "code --wait"`], [Commit messages and rebase lists open in VS Code],
    [`pull.rebase false` #linebreak() or `pull.rebase true`], [Decide once how `git pull` combines diverged branches (#secref(<sec:fetch-pull-push>))],
    [`push.autoSetupRemote true`], [The first `git push` of a new branch creates it on GitHub],
    [`fetch.prune true`], [Remove notes of branches deleted on GitHub],
    [`merge.conflictStyle zdiff3`], [Conflicts also show the original lines],
    [`rerere.enabled true`], [Reuse your resolution when the same conflict returns],
    [`rebase.autoStash true`], [Stash and restore uncommitted edits around a rebase or `pull --rebase`],
    [`rebase.autoSquash true`], [Interactive rebases apply `fixup!` commits automatically],
    [`diff.colorMoved zebra`], [Lines that were moved, not changed, get their own colours in `git diff`],
  )
]

```terminal
git config --global push.autoSetupRemote true
git config --global merge.conflictStyle zdiff3
# ... one line per setting ...
git config --global --list --show-origin    # see every setting and the file it comes from
```

Settings without `--global` apply only to the current repository and override the global ones, which is useful for, say, a different e-mail address in a work project.

== Run checks before every commit: hooks <sec:hooks>

A #term[hook] is a script Git runs at a fixed moment, such as just before a commit is created (`pre-commit`) or before a push (`pre-push`). If the script exits with a non-zero code, Git stops. Hooks live in `.git/hooks`, which is not part of the repository, so to share them with a team, keep them in a tracked folder and point Git at it.

```sh
#!/bin/sh
# .githooks/pre-commit: refuse to commit .env files or files over 50 MB
if git diff --cached --name-only | grep -qE '(^|/)\.env$'; then
  echo "pre-commit: refusing to commit a .env file" >&2
  exit 1
fi
git diff --cached --name-only --diff-filter=AM | while IFS= read -r f; do
  if [ "$(git cat-file -s ":$f")" -gt 52428800 ]; then
    echo "pre-commit: $f is over 50 MB; use Git LFS instead" >&2
    exit 1
  fi
done || exit 1
```

```terminal
git config core.hooksPath .githooks       # once per clone
chmod +x .githooks/pre-commit             # macOS/Linux only
```

Git for Windows runs hooks with its bundled shell, so the same script works in PowerShell sessions. `git commit --no-verify` skips the hooks, which shows what hooks are: a safety net against accidents, not a security control.

#note[
  #strong[The pre-commit framework.] Python projects often use #link("https://pre-commit.com")[pre-commit], which installs ready-made hooks from a configuration file. After `pip install pre-commit`, commit a `.pre-commit-config.yaml` such as

  ```text
  repos:
    - repo: https://github.com/pre-commit/pre-commit-hooks
      rev: v5.0.0
      hooks:
        - id: check-added-large-files
        - id: detect-private-key
        - id: end-of-file-fixer
        - id: trailing-whitespace
  ```

  and run `pre-commit install` once per clone. Every commit is then checked; `pre-commit run --all-files` checks the whole project.
]

== Submodules, shallow and partial clones <sec:submodules>

#note[
  #strong[Submodules] embed one repository inside another at a fixed commit, for example a shared course library used by several projects. `git submodule add <url> libs/course-tools` records it in `.gitmodules`; the parent repository stores only #emph[which commit] of the submodule to use. Anyone cloning must ask for the submodules too:

  ```terminal
  git clone --recurse-submodules git@github.com:USERNAME/project.git
  git submodule update --init --recursive     # if you already cloned without them
  ```

  Submodules are easy to get out of step; for a few shared files, copying them or installing the library as a package is often simpler.

  #strong[Shallow and partial clones] save time on very large repositories. `git clone --depth 1 <url>` downloads only the newest commit, enough to run the code but not to explore history. `git clone --filter=blob:none <url>` downloads every commit but fetches old file contents only when a command needs them.
]

#summary[
  - `git stash` shelves uncommitted work for a short interruption; `pop` brings it back, `-u` includes untracked files.
  - Annotated tags mark releases and submissions permanently; push them explicitly; GitHub releases add notes and files.
  - `git worktree` gives one repository several working folders on different branches.
  - Aliases and a handful of global settings remove most of Git's everyday friction.
  - Hooks run checks automatically; share them with `core.hooksPath` or the pre-commit framework.
  - Submodules pin another repository at a commit; shallow and partial clones save time on large ones.
]

#exercises[
  Set up your own toolkit and use each piece once in `todo-app`.

  + Add the aliases `lg` and `st`, and three settings from the configuration table that you did not have.
  + Start an edit, stash it with a message, make and commit a different change, and pop the stash.
  + Tag the current commit `v0.1.0` with an annotated tag, push it, and find it under #strong[Releases] on GitHub.
  + Add the `pre-commit` hook from this chapter, create a file named `.env`, and confirm that `git commit` refuses it.
]

#questions[
  + You stashed with `git stash`, then with `git stash -m "B"`. Which one does `git stash pop` apply?
  + Why should a submission be marked with a tag rather than a branch?
  + You ran `git push` after `git tag -a v1.1.0`. Is the tag on GitHub?
  + When is a worktree better than a stash?
]

#answers[
  + The newest, `stash@{0}`: the one described `B`.
  + A tag never moves, so it always identifies exactly the submitted commit; a branch label moves with every new commit.
  + No. Tags must be pushed explicitly: `git push origin v1.1.0`, or `git push --follow-tags`.
  + When the interruption is long, or you need both branches' files at the same time (running one while editing the other).
]
