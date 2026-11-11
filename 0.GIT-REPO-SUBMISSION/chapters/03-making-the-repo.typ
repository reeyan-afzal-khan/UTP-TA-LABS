#import "/.shared/typst/utp.typ": *
#unit("chapters", "03-making-the-repo")


#heading(level: 1)[Create and submit the course repository]
 <ch:repo-submission>


#heading(level: 3)[Create an empty GitHub repository]


Choose one method below to create an empty remote repository: use the GitHub website steps or the optional terminal commands. Do not complete both methods.

+ Sign in to GitHub. In the upper-right corner, select the #strong[\+] menu and choose #strong[New repository].

+ Choose the account or organization that should own the repository.

+ Enter a repository name, such as `UTP-course-name`, and select the visibility required by your instructor.

+ Leave #strong[Add a README file] unchecked, and leave the #strong[.gitignore] template and license set to #strong[None].

+ Select #strong[Create repository]. Keep the new repository page open; you will connect it to your local project in the next section.


#heading(level: 3)[Prepare the local project and connect it to GitHub]


Do not upload the virtual environment, passwords, tokens, or API keys. In the project root, create a file named `.gitignore`.

From the project root, create the first commit and connect it to the empty GitHub repository. Replace `USERNAME` and `REPOSITORY`:

#code-block("git init -b main\ngit add .\ngit status\ngit commit -m \"initial commit\"\n\ngit remote add origin git@github.com:USERNAME/REPOSITORY.git\ngit remote -v\ngit push -u origin main", lang: "text")

#callout("pitfall", title: [Common mistake])[Always read `git status` before committing. If a dataset, password, token, `.env` file, or virtual environment appears, stop and update `.gitignore` before running `git commit`.]
