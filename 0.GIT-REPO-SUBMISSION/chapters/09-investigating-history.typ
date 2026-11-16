#import "/.shared/typst/utp.typ": *
#import "git-figures.typ": *
#unit("chapters", "09-investigating-history")

= Searching and debugging history <ch:investigate>

#chapterguide[#chapref(<ch:saving-work>) (`git log`, `git show`, `git diff`) and #chapref(<ch:branches>) (branches and `HEAD~n`).][name any commit or range of commits precisely; filter the log by author, date, message, file and content; find when a line of code was added or removed; ask who last changed each line and why with `git blame`; and find the exact commit that introduced a bug with `git bisect`, by hand or automatically.]

A repository is more than a backup: it is a searchable record of every decision in the project. When a test that used to pass now fails, when a model's accuracy quietly drops, or when you meet a line of code and wonder why it is there, the answer is usually in the history, if you know how to ask.

== Name commits and ranges <sec:ranges>

Most commands that take a commit accept any of these names:

#utptable[
  #tabularx(
    columns: (30%, 1fr),
    header: ([You write], [It means]),
    [`4c2a9e1`], [The commit whose hash starts with these characters (at least four, unique in the repository)],
    [`main`, `origin/main`, `v1.0.0`], [The commit a branch, remote-tracking branch or tag points at],
    [`HEAD`, `HEAD~3`], [The current commit; three first-parent steps before it],
    [`HEAD^2`], [The second parent of a merge commit],
    [`@{u}`], [The upstream of the current branch, such as `origin/main`],
    [`HEAD@{2}`], [Where `HEAD` was two moves ago, from the reflog],
    [`main@{yesterday}`], [Where `main` pointed yesterday on #emph[this] computer, from the reflog],
  )
]

Two-dot and three-dot ranges compare branches:

#utptable[
  #tabularx(
    columns: (30%, 1fr),
    header: ([Range], [Selects]),
    [`git log main..feature`], [Commits on `feature` that are not on `main`: what merging `feature` would bring in],
    [`git log feature..main`], [Commits on `main` that `feature` does not have yet],
    [`git log main..`], [The same as `main..HEAD`: your branch's own commits],
    [`git log @{u}..`], [Commits you have not pushed yet],
    [`git log main...feature`], [Commits on either branch but not both: everything since they split],
    [`git diff main...feature`], [Changes made on `feature` since it split from `main`, ignoring what `main` did since: what a pull request shows],
  )
]

== Filter the log <sec:filter-log>

`git log` accepts filters that can be combined freely:

```terminal
git log --oneline --author="Aisha"              # commits by an author (part of name or e-mail)
git log --oneline --since="2 weeks ago"         # also --until="2026-11-01"
git log --oneline --grep="login" -i             # message contains "login", any case
git log --oneline -- style.css                  # commits that changed style.css
git log --oneline --follow -- docs/guide.md     # ... following the file across renames
git log --oneline --no-merges                   # skip merge commits
git log --oneline --first-parent main           # only the merges and commits made on main itself
git log --stat -5                               # last five commits with files changed
git shortlog -sn                                # commit count per author
```

The `--` separates commit names from file names; use it whenever a file could be mistaken for a branch.

== Search the content of every version <sec:pickaxe>

`--grep` searches commit #emph[messages]. To search the #emph[changes] themselves, use the #term[pickaxe]:

```terminal
git log -S "darkMode" --oneline          # commits where the number of "darkMode" occurrences changed
git log -G "fetch\(.*tasks" --oneline    # commits whose diff has a line matching a regular expression
git log -S "API_KEY" -p                  # ... and show those diffs
```

`-S` is the fastest way to answer #emph[when was this function added?] and #emph[when did this line disappear?]. `-G` also catches commits that only moved or edited a matching line.

`git grep` searches the files themselves, much faster than a general search tool because it reads only tracked files, and it can search any version without checking it out:

```terminal
git grep -n "TODO"                  # tracked files in your working folder, with line numbers
git grep -n "learning_rate" v1.0.0  # the same search in the commit tagged v1.0.0
git grep -c "import torch"          # count of matches per file
```

== Ask who changed a line, and why: `git blame` <sec:blame>

`git blame` prints each line of a file beside the commit that last changed it:

```terminal
$ git blame -L 1,4 index.html
^3741b16 (Your Name  2026-11-02 14:03:11 +0800 1) <h1>Team Tasks</h1>
1a7c4e9b (Teammate   2026-11-09 10:21:45 +0800 2) <ul id="tasks"></ul>
9c1e2f4a (Your Name  2026-11-03 16:40:02 +0800 3) <form id="new-task">
9c1e2f4a (Your Name  2026-11-03 16:40:02 +0800 4)   <input name="task" placeholder="New task">
```

`-L 1,4` limits it to lines 1--4; a `^` marks lines unchanged since the first commit. Take any hash to `git show` to read the whole change and its message: the #emph[why] is in the message, which is another reason to write good ones.

#utptable[
  #tabularx(
    columns: (30%, 1fr),
    header: ([Option], [Effect]),
    [`-w`], [Ignore whitespace changes, so re-indenting does not hide the real author],
    [`-C`], [Detect lines moved or copied from other files in the same commit],
    [`--ignore-rev <hash>`], [Skip one commit, such as a mass reformatting],
    [`--ignore-revs-file .git-blame-ignore-revs`], [Skip every commit listed in that file; GitHub's blame view reads the same file automatically],
  )
]

On GitHub, open a file and choose #strong[Blame] for the same view, with a button beside each change to step back to the version before it. Despite its name, `blame` is for understanding code, not for accusing people; most of the time the line you are puzzling over was written by you.

== Find the commit that broke it: `git bisect` <sec:bisect>

The task counter worked at the tag `v1.0.0` and is wrong today, 60 commits later. Reading 60 diffs is slow. `git bisect` does a binary search instead: it checks out the commit halfway between a known good and a known bad one, you test it and say which it is, and it halves the range again. Each answer halves the search, so 60 commits take about six tests, and 1,000 commits about ten.

#utpfig([`git bisect` halving the search. Between the last good commit and the first known bad one, each test rules out half of the remaining commits. Here three tests are enough to find F, the first bad commit, among nine.], label: <fig:bisect>)[
  #canvas({
    let names = ("A", "B", "C", "D", "E", "F", "G", "H", "I")
    for (i, l) in names.enumerate() {
      let style = if l == "A" { ggood } else if l == "I" { gbad } else if l == "F" { gnew } else { gcommit }
      node((i * 1.35, 0), l, name: l, ..style)
      if i > 0 { connect(names.at(i - 1), l, ..gparent) }
    }
    node(below-of("A", 0.25), [good (`v1.0.0`)], ..gnote)
    node(below-of("I", 0.25), [bad (`HEAD`)], ..gnote)
    node(above-of("E", 0.3), [test 1: E is good], ..gnote)
    node(above-of("G", 0.3), [test 2: G is bad], ..gnote)
    node(below-of("F", 0.25), [test 3: F is bad #sym.arrow.r first bad commit], ..gnote)
  })
]

```terminal
$ git bisect start
$ git bisect bad                  # the current commit is broken
$ git bisect good v1.0.0          # this one worked
Bisecting: 29 revisions left to test after this (roughly 5 steps)
[a1b2c3d] Add task counter
```

Git has checked out a commit in the middle. Test it (open the page, run the code), then report:

```terminal
$ git bisect good                 # or: git bisect bad
Bisecting: 14 revisions left to test after this (roughly 4 steps)
...
4c2a9e1d is the first bad commit
commit 4c2a9e1d...
    Count tasks with a reduce
$ git bisect reset                # return to where you started
```

If a commit cannot be tested (it does not build, for instance), `git bisect skip` moves to a neighbour. `git bisect log` prints your answers so far, and `git bisect reset` ends the session at any time.

=== Let a script do the testing

If a command can tell good from bad, `git bisect run` does the whole search unattended. The command must exit with code 0 for a good commit, 1--127 (except 125) for a bad one, and 125 to skip:

```terminal
git bisect start HEAD v1.0.0
git bisect run python -m pytest tests/test_counter.py -q
git bisect reset
```

The same works for a quality threshold in a machine-learning project. A short script that trains or evaluates quickly and fails when the score drops finds the commit that hurt the model:

```python
# check_accuracy.py: exit 1 (bad) if validation accuracy falls below 0.85
import sys
from evaluate import validation_accuracy   # your project's own function

accuracy = validation_accuracy(seed=0)
print(f"accuracy = {accuracy:.3f}")
sys.exit(0 if accuracy >= 0.85 else 1)
```

```terminal
git bisect start HEAD v1.0.0
git bisect run python check_accuracy.py
```

#warning[
  Bisect checks out old commits in detached `HEAD` (#secref(<sec:detached-head>)). Commit or stash your own changes before starting, keep the test script outside the repository or untracked so every commit sees the same version of it, and always finish with `git bisect reset`.
]

#summary[
  - Name commits by hash, branch, tag, `HEAD~n`, `HEAD^2`, `@{u}` or the reflog; compare branches with `..` and `...`.
  - Filter `git log` by author, date, message, file and `--first-parent`.
  - `-S` and `-G` search changes; `git grep` searches files in any version.
  - `git blame -w -C` shows who last changed each line; the commit message says why.
  - `git bisect` finds the first bad commit in about $log_2 n$ tests, and `git bisect run` automates it with any script that exits 0 or 1.
]

#exercises[
  In `todo-app`, make ten commits that each add one line to a file `numbers.txt` (the numbers 1 to 10), except that commit 6 writes `six` instead of `6`. Tag the first commit `start`. Then find the culprit twice: by hand with `git bisect good` and `git bisect bad`, and automatically with
  `git bisect run sh -c "! grep -q six numbers.txt"`. Before you start, predict how many tests the search needs.
]

#questions[
  + What is the difference between `git log main..feature` and `git log feature..main`?
  + You want to know when the function `load_data` was deleted from the project. Which command?
  + `git blame` shows that your teammate's #emph[Reformat code] commit last touched every line. How do you see past it?
  + How many tests does `git bisect` need, at most, to search 120 commits?
]

#answers[
  + The first lists commits on `feature` that `main` lacks; the second lists commits on `main` that `feature` lacks.
  + `git log -S "def load_data" --oneline` (add `-p` to see the diff).
  + `git blame -w`, or `--ignore-rev <hash>`, or list the commit in `.git-blame-ignore-revs`.
  + Seven, since $2^7 = 128 >= 120$.
]
