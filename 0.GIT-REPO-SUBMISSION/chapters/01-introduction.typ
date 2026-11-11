#import "/.shared/typst/utp.typ": *
#unit("chapters", "01-introduction")


#heading(level: 1)[Introduction]
 <ch:introduction>

This guide helps you prepare Git and GitHub for coursework. It covers setup, secure access, publishing your project, and submitting updates. Follow the chapters in order, replace examples such as `USERNAME` and `REPOSITORY`, and follow your instructor's repository requirements.

Git tracks changes on your computer; GitHub hosts an online copy of your project. A commit saves a snapshot of your work, and pushing sends it to GitHub for review.


#heading(level: 3, numbering: none)[The workflow]


#block[
#diagram-drawing("/0.GIT-REPO-SUBMISSION/figures/diagrams/3552e0271aaab9a3.cetz.json")

]

#heading(level: 3, numbering: none)[What you will learn]


- Install Git and configure the name and email recorded in your commits.

- Create an SSH key, register its public half, and test your connection safely.

- Initialize a local repository, link it to GitHub, and push the first commit.

- Check, commit, and push later changes so your submitted work stays current.


#heading(level: 3, numbering: none)[Common mistakes to avoid]


- Never add passwords, tokens, API keys, `.env` files, or your private SSH key to a repository.

- Do not commit until `git status` shows only the files you intend to submit.

- Deleting a secret in a later commit does not remove it from earlier repository history.

#block[
+ #strong[Check access.] Sign in to GitHub and confirm that you can access your account.

+ #strong[Install and configure Git.] Follow the installation and commit-identity instructions in Chapter~#ref(label("ch:git-ssh-setup"), supplement: none).

+ #strong[Confirm course requirements.] Check your instructor's repository naming and visibility requirements.

]
