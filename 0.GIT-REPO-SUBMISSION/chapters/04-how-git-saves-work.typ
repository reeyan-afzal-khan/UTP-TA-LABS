#import "/.shared/typst/utp.typ": *
#import "git-figures.typ": *
#unit("chapters", "04-how-git-saves-work")

= How Git saves your work <ch:saving-work>

#chapterguide[#chapref(<ch:repo-submission>): a repository on your computer, linked to GitHub, with one commit pushed.][name the four places your work lives; read `git status` and `git diff` and act on them; stage part of a change; read history with `git log` and `git show`; write commit messages a reviewer can use; keep secrets, environments and stray files out with `.gitignore`; stop line endings from spoiling your diffs; and submit later updates with confidence.]

Most people learn Git as a list of commands to copy. That works until something unexpected appears on the screen, and then there is nothing to reason with. This chapter gives you the picture instead: where your work sits at each moment, and which command moves it. Every later chapter, including the advanced ones, uses the same picture.

#heading(depth: 3, numbering: none)[The running example]

The chapters in this part follow one small project. You and a teammate run a club, and its plans are lost in a group chat, so the two of you build a to-do page that everyone can read. It starts as a single file, `index.html`, and grows a style sheet, a login page and a dark theme. To follow along, make a folder called `todo-app`, save these two lines in it as `index.html`, and turn it into a repository:

```html
<h1>To-Do</h1>
<ul id="tasks"></ul>
```

```terminal
cd todo-app
git init -b main
git status
```

You can run every command in this part inside `todo-app` without touching your course repository. Delete the folder whenever you like and start again.

== The four places your work lives <sec:four-places>

Git keeps your project in four places. Three are on your computer and the fourth is on GitHub.

#utpfig([The four places. Commands along the top send work toward GitHub; commands along the bottom bring it back. Almost every Git command moves work between two of these places, or moves a label such as `main` or `HEAD`.], label: <fig:four-places>)[
  #canvas({
    rectangle((-1.75, -1.55), (9.55, 1.25), draw: mix(blue, 45%), dash: "dashed", rounded: 2mm)
    node((-1.6, 1.05), [Your computer], anchor: "west", ..gnote)
    node((0, 0), [#strong[Working folder] \ #fsize("script")[the files you edit]], name: "work", ..gplace)
    node((3.9, 0), [#strong[Staging area] \ #fsize("script")[the next snapshot]], name: "stage", ..gplace)
    node((7.8, 0), [#strong[Local repository] \ #fsize("script")[commits in `.git`]], name: "repo", ..gplace)
    node((12.0, 0), [#strong[GitHub] \ #fsize("script")[the remote, `origin`]], name: "hub", ..gremoteplace)
    connect((1.45, 0.3), (2.45, 0.3), ..gforward)
    node((1.95, 0.9), gcmd[git add], ..gcmdlabel)
    connect((5.35, 0.3), (6.35, 0.3), ..gforward)
    node((5.85, 0.9), gcmd[git commit], ..gcmdlabel)
    connect((9.25, 0.3), (10.55, 0.3), ..gforward)
    node((9.9, 0.9), gcmd[git push], ..gcmdlabel)
    connect((10.55, -0.3), (9.25, -0.3), ..gback)
    node((9.9, -0.92), gcmd[git fetch], ..gcmdlabel)
    connect((7.8, -0.65), (7.8, -1.1), (0, -1.1), (0, -0.65), ..gback)
    node((3.9, -1.1), gcmd[git switch #h(0.4em) git restore #h(0.4em) git merge], ..gcmdlabel)
  })
]

#describe-nextline(31mm)[
  / Working folder: The ordinary files you open and edit. Git calls it the #term[working tree].
  / Staging area: A tray on which you pack the changes for your next snapshot. Git also calls it the #term[index].
  / Local repository: Every snapshot you have saved, kept in the hidden `.git` folder inside your project. Each snapshot is a #term[commit].
  / Remote: A copy of the repository somewhere else, usually GitHub. Its short name is #term[origin].
]

#note[
  A file can be different in each place at the same time. You may have edited `index.html` (working folder), staged only part of that edit (staging area), while the last commit still holds the old version (local repository) and GitHub holds an even older one. `git status` and `git diff` exist to tell you which differences exist and where.
]

== The everyday loop: status, add, commit <sec:everyday-loop>

=== Read `git status` first

`git status` changes nothing; it only looks. Run it before and after every other command until reading it becomes a habit. Suppose you have started a task form in `index.html` and written a new `style.css`:

```terminal
$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   index.html

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        style.css

no changes added to commit (use "git add" and/or "git commit -a")
```

#utptable[
  #tabularx(
    columns: (27%, 1fr, 31%),
    styles: (navy-bold,),
    header: ([Section of the output], [What it means], [Usual next step]),
    [Changes to be committed], [Staged. These changes are on the tray and go into the next commit. Shown in green.], [`git commit`],
    [Changes not staged for commit], [Git tracks the file and it has changed since the last commit, but the change is not on the tray yet. Shown in red.], [`git add <file>` or `git diff`],
    [Untracked files], [Git has never saved this file. It is not part of any commit.], [`git add <file>`, or list it in `.gitignore`],
    [nothing to commit, working tree clean], [All three local places agree.], [`git push`, or keep working],
  )
]

The grey lines in brackets are Git's own hints. They are usually the right next command.

=== Why there is a staging area

The task form is half finished, but the style sheet is done. If you saved everything now, the snapshot would contain a broken form, and you could never come back to a version where the styles were finished and the page still worked. The staging area lets you choose:

```terminal
git add style.css
git commit -m "Add styles"
git status
```

`style.css` is now in a commit; `index.html` is still listed as modified, untouched and waiting. When the form is finished, `git add .` stages every change in the current folder, and one more commit saves it.

#warning[
  `git add .` stages #emph[everything] Git can see, including files you forgot were there. Run `git status` first, and if anything unexpected appears (a `.env` file, a `.venv/` folder, a 200 MB dataset), stop and add it to `.gitignore` before staging.
]

=== Stage part of a file with `git add -p`

Sometimes one file holds two unrelated changes: a typo fix you want to commit now, and a feature that is not ready. `git add -p` (for #emph[patch]) walks through each changed block of lines, called a #term[hunk], and asks what to do with it:

```terminal
$ git add -p index.html
@@ -1,2 +1,2 @@
-<h1>To-Do</h1>
+<h1>Club To-Do</h1>
 <ul id="tasks"></ul>
(1/2) Stage this hunk [y,n,q,a,d,s,e,?]? y
```

Answer `y` to stage the hunk, `n` to skip it, `s` to split it into smaller hunks, `q` to stop, and `?` for the full list. Afterwards `git diff --staged` shows exactly what will be committed, and `git diff` shows what was left behind.

=== Commit, with or without `-m`

`git commit -m "message"` saves the tray as a commit with a one-line message. Without `-m`, Git opens a text editor for a longer message. If the default editor is unfamiliar, make it VS Code:

```terminal
git config --global core.editor "code --wait"
```

`git commit -am "message"` stages every #emph[tracked] file that changed and commits in one step. It skips untracked files, so a new file you created is silently left out. Use it only when `git status` shows no untracked files you care about.

== See exactly what changed: `git diff` <sec:diff>

`git status` names the files that differ; `git diff` shows the lines. Which two places it compares depends on how you call it.

#utptable[
  #tabularx(
    columns: (32%, 1fr),
    header: ([Command], [Compares]),
    [`git diff`], [Working folder against the staging area: the changes you have #emph[not] staged yet],
    [`git diff --staged`], [Staging area against the last commit: exactly what `git commit` would save],
    [`git diff HEAD`], [Working folder against the last commit: everything you changed, staged or not],
    [`git diff --stat`], [The same comparison, summarised as files and line counts],
    [`git diff main feature/login`], [The newest commits of two branches against each other (#chapref(<ch:branches>))],
  )
]

Here is what you would see after adding the form, before staging it:

```terminal
$ git diff
diff --git a/index.html b/index.html
index 3b18e51..a8c2f04 100644
--- a/index.html
+++ b/index.html
@@ -1,2 +1,6 @@
 <h1>To-Do</h1>
 <ul id="tasks"></ul>
+<form id="new-task">
+  <input name="task" placeholder="New task">
+  <button>Add</button>
+</form>
```

Lines starting with `+` were added and lines starting with `-` were removed; lines starting with a space are unchanged context. The `@@ -1,2 +1,6 @@` header says the hunk covers two lines starting at line 1 in the old version and six lines starting at line 1 in the new one. Press `q` to leave a long diff.

#exercises[
  Stage half of a change and look at it from both sides. Edit two separate lines of `index.html`, stage one with `git add -p`, then run `git diff`, `git diff --staged` and `git diff HEAD`. Before running each one, predict which of your two edits it will show.
]

== Read history: `git log` and `git show` <sec:log>

Every commit has an ID, a 40-character #term[hash] such as `9c1e2f4a7b...`, computed from its contents. Git usually prints the first seven characters, and any unique prefix works in a command. Your hashes will never match the ones in this book.

```terminal
$ git log --oneline
9c1e2f4 (HEAD -> main, origin/main) Add task form
5b7d0a1 Add styles
3741b16 Add task list
```

The newest commit is at the top. `(HEAD -> main, origin/main)` lists the labels that point at that commit; #chapref(<ch:branches>) explains each one. Useful variations:

#utptable[
  #tabularx(
    columns: (38%, 1fr),
    header: ([Command], [Shows]),
    [`git log -3`], [Only the three newest commits],
    [`git log --stat`], [Each commit with the files it changed and how many lines],
    [`git log -p index.html`], [Every commit that touched `index.html`, with its diff],
    [`git log --oneline --graph --all`], [Every branch as a drawing, one line per commit],
    [`git show`], [The newest commit: its author, date, message and full diff],
    [`git show 5b7d0a1`], [The same for any commit, named by its hash],
    [`git show HEAD~1:index.html`], [`index.html` as it was one commit before the newest],
  )
]

`HEAD` means #emph[the commit you are on]. `HEAD~1` is its parent, the commit before it; `HEAD~2` is the one before that. You can use these names anywhere Git expects a commit.

== Write commit messages a reviewer can use <sec:messages>

Your lecturer, your teammate and you in three months will read `git log --oneline` to understand what happened. A message that says #emph[what changed and why] makes that possible; `update` and `stuff` do not.

#utptable[
  #tabularx(
    columns: (34%, 34%, 1fr),
    header: ([Instead of], [Write], [Why]),
    [`stuff`], [`Add task form to index page`], [Says what the commit does],
    [`fixed bug`], [`Fix crash when task list is empty`], [Names the bug, so it can be found again],
    [`final version 2`], [`Tune learning rate to 0.001 for lab 3`], [Git already numbers versions; say what changed],
    [`changes`], [`Move data loading into load_data()`], [One commit, one idea],
  )
]

The convention most projects follow is a short subject line (about 50 characters, written as an instruction: #emph[Add], #emph[Fix], #emph[Remove]), then a blank line, then a body explaining #emph[why], wrapped at about 72 characters. The subject should complete the sentence #emph[If applied, this commit will ...].

```text
Fix crash when task list is empty

The page called tasks[0] before checking the list length, so a new
user with no tasks saw a blank screen. Check the length first and
show "No tasks yet" instead.
```

Make each commit one logical change. Small commits are easier to review, to undo (#chapref(<ch:undo>)) and to search (#chapref(<ch:investigate>)).

== Keep files out: `.gitignore` in depth <sec:gitignore>

`.gitignore` is a text file in the project root listing files Git should not offer to track. Each line is a pattern:

#utptable[
  #tabularx(
    columns: (28%, 1fr),
    header: ([Pattern], [Matches]),
    [`.env`], [A file or folder named `.env` in any folder],
    [`*.log`], [Every file ending in `.log`, anywhere],
    [`.venv/`], [A #emph[folder] named `.venv` and everything inside it; the trailing slash means folders only],
    [`/notes.txt`], [`notes.txt` in the project root only, not in subfolders],
    [`data/raw/`], [The `raw` folder inside `data`],
    [`**/checkpoints/`], [A `checkpoints` folder at any depth],
    [`!data/raw/README.md`], [An exception: track this file even though an earlier pattern ignores its folder's contents. Write the folder pattern as `data/raw/*` so the exception can work],
    [`# comment`], [Nothing; lines starting with `#` are notes],
  )
]

A reasonable starting point for a Python or Jupyter course repository:

```text
# secrets and local settings
.env
*.key

# Python environments and caches
.venv/
venv/
__pycache__/
*.py[cod]

# Jupyter and editors
.ipynb_checkpoints/
.vscode/
.DS_Store
Thumbs.db

# large or generated files: keep them out unless your instructor asks for them
*.zip
*.pt
*.pth
*.h5
results/tmp/
```

GitHub keeps maintained templates for most languages at #link("https://github.com/github/gitignore")[github.com/github/gitignore]. Start from one and add your course's own folders.

=== When a file is ignored, or not

Two commands answer #emph[why is this file (not) showing up?]

```terminal
git check-ignore -v .venv/lib/site.py    # which .gitignore line ignores it
git status --ignored                     # list ignored files too
```

#warning[
  `.gitignore` only affects files Git is #emph[not already tracking]. If you committed `.env` before ignoring it, Git keeps tracking it. Stop tracking it while keeping your local copy with `git rm --cached .env`, then commit. The old commits still contain the file, so if it held a password or key, treat that secret as leaked: #chapref(<ch:repo-hygiene>) shows what to do.
]

Patterns that belong to #emph[you] rather than the project, such as your editor's files, can go in a global ignore file that applies to every repository on your computer:

```terminal
# macOS/Linux Terminal or Git Bash
git config --global core.excludesFile ~/.gitignore_global

# Windows PowerShell
git config --global core.excludesFile "$env:USERPROFILE\.gitignore_global"
```

== Line endings across Windows, macOS and Linux <sec:line-endings>

Windows ends each line of a text file with two invisible characters, carriage return and line feed (#term[CRLF]); macOS and Linux use only the line feed (#term[LF]). When a team mixes systems, a file can appear to change on every line although nobody edited it, and a shell script saved with CRLF fails on Linux with errors such as `$'\r': command not found`. You may also see this warning, which is harmless on its own:

```terminal
warning: in the working copy of 'index.html', LF will be replaced by CRLF the next time Git touches it
```

The fix that works for everyone, whatever their own settings, is a `.gitattributes` file in the project root, committed like any other file:

```text
# let Git normalise text files to LF inside the repository
* text=auto

# files that must keep one style on every system
*.sh   text eol=lf
*.bat  text eol=crlf

# never touch binary files
*.png  binary
*.jpg  binary
*.pdf  binary
```

If the repository already has files with mixed endings, normalise them once after adding `.gitattributes`:

```terminal
git add --renormalize .
git commit -m "Normalise line endings"
```

#note[
  Git for Windows asks about line endings during installation and by default sets `core.autocrlf` to `true`: files are checked out with CRLF and committed with LF. That setting is personal; `.gitattributes` travels with the repository and wins for everyone, which is why teams prefer it.
]

== Submit updates to your course repository <sec:submit-updates>

#chapref(<ch:repo-submission>) pushed your first commit. Every later submission is the same short loop, and the four places explain each step.

#tip[
  #listopts(leftmargin: 1.7em, itemsep: 0.35em, topsep: 0.3em)[
    + `git status` --- see what changed and confirm nothing unexpected is listed.
    + `git diff` --- read the changes you are about to submit.
    + `git add <files>` --- stage the finished work only.
    + `git diff --staged` --- check the tray one last time.
    + `git commit -m "Complete lab 3 questions 1-4"` --- save the snapshot.
    + `git push` --- send it to GitHub, then refresh the repository page and check the files are there.
  ]
]

A commit is not a submission. Until you push, the commit exists only on your computer, and `git status` says so:

```terminal
$ git status
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```

`origin/main` is your computer's note of where GitHub's `main` was the last time the two talked. #emph[Ahead by 1] means one commit exists here that GitHub has not received. After `git push` the message becomes `Your branch is up to date with 'origin/main'`.

#note[
  #strong[Under the hood: what a commit really is.] A commit is a small text object stored in `.git/objects`. Ask Git to print the newest one:

  ```terminal
  $ git cat-file -p HEAD
  tree 4b825dc642cb6eb9a060e54bf8d69288fbee4904
  parent 5b7d0a1c3e9f2a4b6d8c0e1f3a5b7c9d1e3f5a7b
  author Your Name <you@example.com> 1763107200 +0800
  committer Your Name <you@example.com> 1763107200 +0800

  Add task form
  ```

  The #emph[tree] is a snapshot of the whole folder, listing every file by the hash of its contents (`git cat-file -p HEAD^{tree}` prints it). The #emph[parent] is the commit before this one. Because each hash is computed from the contents, including the parent's hash, changing any old commit changes every hash after it. That is why rewriting shared history (#chapref(<ch:rebase>)) causes trouble, and why a file that has not changed is stored only once however many commits contain it.
]

#summary[
  - Work lives in four places: the working folder, the staging area, the local repository and the remote. `add`, `commit` and `push` move it toward GitHub.
  - `git status` names what differs; `git diff`, `git diff --staged` and `git diff HEAD` show the lines.
  - Stage only finished work; `git add -p` stages part of a file.
  - `git log --oneline`, `git show` and `HEAD~n` let you read and name any commit.
  - A good message says what changed and why, in one short subject line and an optional body.
  - `.gitignore` keeps untracked files out; `git rm --cached` stops tracking a file; `.gitattributes` fixes line endings for the whole team.
  - Committing saves; pushing submits.
]

#questions[
  + You ran `git add index.html`, then edited `index.html` again. Which version will `git commit` save, and which command shows the difference between the two?
  + `git status` lists `secrets.env` under #emph[Untracked files]. You add `secrets.env` to `.gitignore`. What does `git status` show now, and why would the same step not have helped if the file were listed under #emph[Changes not staged for commit]?
  + Your teammate says #emph[I can't see your fix on GitHub], and you are sure you committed it. Name the one command that tells you who is right.
]

#answers[
  + The staged version, the one on the tray when you ran `git add`. `git diff` shows the later edit that is not staged; `git add index.html` again would stage it.
  + It no longer lists `secrets.env`; it lists the changed `.gitignore` instead. A file under #emph[Changes not staged] is already tracked, and `.gitignore` never affects tracked files: you would need `git rm --cached secrets.env` too.
  + `git status`. If it says #emph[ahead of 'origin/main'], the commit was never pushed.
]
