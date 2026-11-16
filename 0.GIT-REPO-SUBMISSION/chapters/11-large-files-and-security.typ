#import "/.shared/typst/utp.typ": *
#import "git-figures.typ": *
#unit("chapters", "11-large-files-and-security")

= Large files, notebooks and secrets <ch:repo-hygiene>

#chapterguide[#chapref(<ch:saving-work>) (`.gitignore` and `.gitattributes`), #chapref(<ch:undo>) (rewriting history) and the SSH key from #chapref(<ch:git-ssh-setup>).][decide what belongs in a repository; store datasets and trained models with Git LFS, or keep them out; keep Jupyter notebooks reviewable; respond correctly when a password or API key has been pushed, including removing it from history; and sign your commits with your SSH key so GitHub marks them #emph[Verified].]

Machine-learning and data projects stretch Git in three ways that small web projects do not: their files are big, their notebooks mix code with output, and they talk to online services with secret keys. Each problem has a standard answer. Knowing them in advance is far easier than repairing a repository after a 2 GB model or a cloud key has been pushed.

== What belongs in a repository <sec:what-belongs>

#utptable[
  #tabularx(
    columns: (50%, 1fr),
    header: ([Commit it], [Keep it out]),
    [Source code, scripts and notebooks], [Virtual environments (`.venv/`), caches (`__pycache__/`)],
    [`requirements.txt` or `environment.yml`], [Installed packages; they are rebuilt from the requirements file],
    [README, data cards, small configuration files], [Passwords, tokens, API keys and `.env` files],
    [Small sample data that the code needs to run], [Raw datasets of more than a few megabytes, unless your instructor asks for them],
    [`.gitignore`, `.gitattributes`], [Trained models and checkpoints, unless stored with Git LFS],
    [Figures and results your submission must include], [Outputs that a script regenerates in seconds],
  )
]

GitHub enforces hard limits. A push containing any file over 100 MiB is rejected, files over 50 MiB produce a warning, and GitHub recommends keeping a whole repository under 1 GB. Every version of every file is kept forever, so a 300 MB model retrained ten times costs 3 GB of history, even if only the newest version is in your folder.

```terminal
remote: error: File models/cnn.pt is 312.45 MB; this exceeds GitHub's file size limit of 100.00 MB
remote: error: GH001: Large files detected. You may want to try Git Large File Storage ...
 ! [remote rejected] main -> main (pre-receive hook declined)
```

#warning[
  Deleting the big file and committing again does not fix this error: the file is still in the earlier, unpushed commit, and the push still contains it. Undo the commit that added it (`git reset --soft` to before it, #secref(<sec:reset>)), add the file to `.gitignore` or to Git LFS, and commit again.
]

== Store large files with Git LFS <sec:lfs>

#term[Git LFS] (Large File Storage) keeps large files outside the normal history. Git commits a small text #emph[pointer] in place of each tracked file, and the file itself is uploaded to separate LFS storage. Cloning downloads only the versions you check out, not every version ever committed.

Git for Windows includes LFS. On macOS install it with `brew install git-lfs`, and on Debian or Ubuntu with `sudo apt install git-lfs`. Then:

```terminal
git lfs install                       # once per computer
git lfs track "*.pt" "*.h5"           # once per repository: which files go to LFS
git add .gitattributes                # the tracking rules live here; commit them
git add models/cnn.pt
git commit -m "Add trained CNN weights"
git push
git lfs ls-files                      # check which files LFS is storing
```

`git lfs track` writes lines such as `*.pt filter=lfs diff=lfs merge=lfs -text` into `.gitattributes`. Track the pattern #emph[before] adding the files. If large files were already committed normally, `git lfs migrate import --include="*.pt" --everything` rewrites the history to move them into LFS, after which every branch must be force-pushed and collaborators must clone again.

#note[
  GitHub's LFS storage and download bandwidth are limited on free accounts and counted against the repository owner. For large datasets, the usual alternatives are a download script plus a data card in the README, a data-versioning tool such as DVC, or a dataset hub. Follow your course's own rules: some labs ask for a `results/` folder to be committed and data to be left out.
]

== Keep notebooks reviewable <sec:notebooks>

A Jupyter notebook is a JSON file. Besides code, it stores every output, embedded images and execution counts, so rerunning a single cell can change hundreds of lines and a plotted figure can add megabytes. Outputs can also contain data you did not mean to publish, such as the first rows of a private table.

#utptable[
  #tabularx(
    columns: (32%, 1fr),
    header: ([Tool], [What it gives you]),
    [Clear outputs before committing], [In JupyterLab, #strong[Edit] #sym.arrow.r #strong[Clear Outputs of All Cells], then save. Small, clean diffs],
    [`nbstripout`], [After `pip install nbstripout` and `nbstripout --install` in the repository, outputs are stripped automatically from what is committed, while your local notebook keeps them],
    [`nbdime`], [`pip install nbdime`, then `nbdime config-git --enable --global`: `git diff` on notebooks shows code and outputs cell by cell instead of raw JSON],
    [GitHub's notebook view], [Pull requests render notebooks and offer a #strong[rich diff] toggle],
  )
]

#warning[
  Many lab sheets, including those in this collection's Machine Learning course, ask you to submit the #emph[executed] notebook with its outputs. Do not strip outputs in a submission repository. Use `nbdime` there for readable diffs, and keep `nbstripout` for projects where outputs are regenerated.
]

== When a secret has been committed <sec:leaked-secrets>

An API key, token or password pushed to GitHub must be treated as stolen. Automated scanners watch public pushes and can find a key within minutes, and removing it in a later commit leaves it readable in the history (#chapref(<ch:introduction>) warned you). The order of the steps matters:

#utpsteps[
  + #strong[Revoke or rotate the secret first.] Delete the key or change the password at the service that issued it. Nothing you do to the repository protects a key someone has already copied.
  + #strong[Stop using it in code.] Read secrets from the environment, list `.env` in `.gitignore`, and commit a `.env.example` with the variable names and placeholder values.
  + #strong[Remove it from history] if the repository will stay public or shared (below).
  + #strong[Tell your collaborators] to delete their clones and clone again; an old clone still contains the secret and would push it back.
]

```python
# read the key from the environment, never from the source file
import os
from dotenv import load_dotenv     # pip install python-dotenv

load_dotenv()                      # reads .env, which .gitignore keeps out of Git
api_key = os.environ["WEATHER_API_KEY"]
```

=== Remove a file or a string from every commit

The recommended tool is `git filter-repo`. It rewrites every commit, so run it in a #emph[fresh clone], and expect every commit hash after the first affected one to change.

```terminal
pip install git-filter-repo
git clone git@github.com:USERNAME/todo-app.git todo-app-clean
cd todo-app-clean

git filter-repo --invert-paths --path .env           # delete .env from all history
# or, to blank out a key inside a file that must stay:
git filter-repo --replace-text ../replacements.txt
```

`replacements.txt` lives outside the repository and holds one line per secret, `the-literal-key==>REMOVED`. For safety, `filter-repo` removes the `origin` remote when it finishes, so add it back and force-push every branch and tag:

```terminal
git remote add origin git@github.com:USERNAME/todo-app.git
git push origin --force --all
git push origin --force --tags
```

Copies of the old commits can survive in forks, open pull requests and GitHub's caches; GitHub's documentation on removing sensitive data explains how to ask its support team to purge them. This is why step 1, revoking the secret, comes first.

#note[
  GitHub's #strong[push protection] blocks many pushes that contain recognisable tokens (cloud keys, GitHub tokens and others) and explains why in the push output. Treat a block as a warning to rotate the key and fix the commit, not as an obstacle to bypass.
]

== Sign your commits <sec:signing>

`user.name` and `user.email` are just settings (#chapref(<ch:git-ssh-setup>)): anyone can set them to your name and push a commit that appears to be yours. A #term[signed commit] carries a cryptographic signature from your key, and GitHub shows a #strong[Verified] badge beside it. Since Git 2.34 you can sign with the SSH key you already made.

Tell Git to sign with SSH, and to sign every commit and tag:

```terminal
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Then name the key. On macOS and Linux:

```terminal
git config --global user.signingkey ~/.ssh/id_ed25519.pub
```

On Windows PowerShell, also point Git at Windows' own OpenSSH, the same one #chapref(<ch:git-ssh-setup>) set up with its SSH agent:

```terminal
git config --global user.signingkey "$env:USERPROFILE\.ssh\id_ed25519.pub"
git config --global gpg.ssh.program "C:/Windows/System32/OpenSSH/ssh-keygen.exe"
```

Finally, register the same public key on GitHub a second time, as a signing key:

#listopts(leftmargin: 1.7em)[
  + Copy the public key as in #chapref(<ch:git-ssh-setup>).
  + On GitHub, open #strong[Settings] #sym.arrow.r #strong[SSH and GPG keys] and click #strong[New SSH key].
  + Set #strong[Key type] to #strong[Signing Key] (not #emph[Authentication Key]), paste the key and save.
]

Make a commit and push it; on GitHub the commit list shows #strong[Verified]. Annotated tags are signed too, because of `tag.gpgsign`.

#note[
  #strong[Checking signatures locally.] `git log --show-signature` needs a list of trusted keys. Create it once, then point Git at it:

  ```terminal
  # macOS/Linux Terminal or Git Bash
  echo "$(git config user.email) namespaces=\"git\" $(cat ~/.ssh/id_ed25519.pub)" >> ~/.ssh/allowed_signers
  git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers

  # Windows PowerShell
  $line = "$(git config user.email) namespaces=`"git`" $(Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub)"
  Add-Content "$env:USERPROFILE\.ssh\allowed_signers" $line
  git config --global gpg.ssh.allowedSignersFile "$env:USERPROFILE\.ssh\allowed_signers"
  ```

  `git log --show-signature -1` then reports #emph[Good "git" signature] for your commits. In GitHub's SSH and GPG keys settings, #strong[Flag unsigned commits as unverified] (vigilant mode) labels every unsigned commit attributed to you as #emph[Unverified].
]

#summary[
  - Commit code, small data and requirements; keep environments, secrets and large data out. GitHub rejects files over 100 MiB.
  - Git LFS stores large files as pointers; track patterns before adding files, and mind storage quotas.
  - Keep notebooks reviewable with `nbdime`; strip outputs only where submissions do not need them.
  - A pushed secret is stolen: revoke it first, then move it to the environment, purge it with `git filter-repo`, force-push and have collaborators re-clone.
  - Sign commits and tags with your SSH key (`gpg.format ssh`) and register it on GitHub as a signing key to earn the Verified badge.
]

#exercises[
  Audit your own course repository.

  + Run `git count-objects -vH` and note `size-pack`, the size of the history on disk. Find the largest files ever committed with `git log --all --stat` or by browsing the repository on GitHub.
  + Search all history for words that should never be there: `git log -p --all -S "password"`, then the same for `api_key` and `token`.
  + Set up commit signing and push one signed commit. Check for the #strong[Verified] badge.
]

#questions[
  + Your push fails with #emph[GH001: Large files detected]. You delete the file and commit again; the push still fails. Why?
  + In what order should you handle a leaked API key: rewrite history, or revoke the key?
  + Why must you run `git lfs track` before `git add` for a model file?
  + What does the #strong[Verified] badge prove that `user.email` alone does not?
]

#answers[
  + The earlier commit that added the file is still part of the push. Remove that commit (for example `git reset --soft` to before it), then commit without the file or track it with LFS.
  + Revoke or rotate the key first; rewriting history afterwards limits further exposure but cannot recall a key that was already copied.
  + Tracking decides how the file is stored when it is added. A file added before the rule is committed as an ordinary Git file and stays in the history at full size.
  + That the commit was signed by a key registered to the GitHub account, not just labelled with that account's e-mail address.
]
