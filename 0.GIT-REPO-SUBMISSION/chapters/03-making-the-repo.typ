#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-making-the-repo")

= Create and submit the course repository <ch:repo-submission>

=== Create an empty GitHub repository

Choose one method below to create an empty remote repository: use the GitHub website steps or the optional terminal commands. Do not complete both methods.

#listopts(leftmargin: 1.7em, itemsep: 0.35em, topsep: 0.4em)[
  + Sign in to GitHub. In the upper-right corner, select the #strong[\+] menu and choose #strong[New repository].
  + Choose the account or organization that should own the repository.
  + Enter a repository name, such as `UTP-course-name`, and select the visibility required by your instructor.
  + Leave #strong[Add a README file] unchecked, and leave the #strong[.gitignore] template and license set to #strong[None].
  + Select #strong[Create repository]. Keep the new repository page open; you will connect it to your local project in the next section.
]

=== Prepare the local project and connect it to GitHub

Do not upload the virtual environment, passwords, tokens, or API keys. In the project root, create a file named `.gitignore`.

From the project root, create the first commit and connect it to the empty
GitHub repository. Replace `USERNAME` and `REPOSITORY`:

```terminal
git init -b main
git add .
git status
git commit -m "initial commit"

git remote add origin git@github.com:USERNAME/REPOSITORY.git
git remote -v
git push -u origin main
```

#warning[
  Always read `git status` before committing. If a dataset, password,
  token, `.env` file, or virtual environment appears, stop and update
  `.gitignore` before running `git commit`.
]

Your first submission is now on GitHub. Submit every later update with the short loop in #secref(<sec:submit-updates>), and see #secref(<sec:gitignore>) for a starter `.gitignore`.
