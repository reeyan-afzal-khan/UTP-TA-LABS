#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-installing-git-and-ssh")


#heading(level: 1)[Install Git and configure SSH]
 <ch:git-ssh-setup>

#strong[Choose one Git installation method.] Install Git from the official website or use the terminal commands below. If Git is already installed, skip both methods and verify it with `git --version`.


#heading(level: 3)[Option 1: Install Git from the official website]


#block[
Follow Git's official installation instructions for your platform.

#block[
#block[
#strong[Windows]

#link("https://git-scm.com/install/windows")[#strong[Installation guide $arrow.r$]]

]
]
#block[
#block[
#strong[macOS]

#link("https://git-scm.com/install/mac")[#strong[Installation guide $arrow.r$]]

]
]
#block[
#block[
#strong[Linux]

#link("https://git-scm.com/install/linux")[#strong[Installation guide $arrow.r$]]

]
]
]

#heading(level: 3)[Option 2: Install Git from the terminal]


Use this option instead of the website instructions above. Run the command for your operating system, then reopen the terminal:

#code-block("# Windows PowerShell\nwinget install --id Git.Git -e --source winget\n\n# macOS (Option A): install using Homebrew\nbrew install git\n\n# macOS (Option B - If you don't have brew installed): install Apple's command-line tools\nxcode-select --install\n\n# Linux\nsudo apt update\nsudo apt install git", lang: "text")

For SSH setup, use #strong[PowerShell] on Windows or #strong[Terminal] on macOS and Linux. The commands are labeled by platform. After either installation method, confirm Git is available:

#code-block("git --version", lang: "text")


#heading(level: 3)[Configure your commit identity]


Set the name and email that should appear on future commits. Use an email connected to your GitHub account, or your GitHub-provided private email.

#code-block("git config --global user.name \"Your Name\"\ngit config --global user.email \"you@example.com\"\ngit config --global init.defaultBranch main\n\ngit config --global --list", lang: "text")

#strong[Choose one SSH setup option.] Option 1 uses video walkthroughs; Option 2 provides written terminal instructions. Both cover the SSH setup, so follow the path you prefer and skip steps already completed.


#heading(level: 3)[Option 1: SSH setup with video walkthroughs]


#block[
Open the matching video guide for SSH setup.

#block[
#block[
#strong[Windows]

#link("https://youtu.be/YT5YimhyX18?t=5")[#strong[View video guide $arrow.r$]]

]
]
#block[
#block[
#strong[macOS]

#link("https://youtu.be/ACvE5Uy7ZB0?t=437")[#strong[View video guide $arrow.r$]]

]
]
#block[
#block[
#strong[Linux]

#link("https://youtu.be/AOM8CEyu3Ug?t=121")[#strong[View video guide $arrow.r$]]

]
]
]

#heading(level: 3)[Option 2: SSH setup from the terminal]


SSH lets Git authenticate without asking for a GitHub password on every push. The key-generation process is similar across operating systems. Use PowerShell on Windows or Terminal on macOS and Linux. The `ssh-keygen` command is the same; the commands for checking existing keys and loading them into the SSH agent are shown separately by platform.

First check whether this computer already has a key:

#code-block("# Windows PowerShell\nGet-ChildItem -Force \"$env:USERPROFILE\\.ssh\"\n\n# macOS/Linux Terminal\nls -al ~/.ssh", lang: "text")

If `id_ed25519` and `id_ed25519.pub` do not exist, create them. Enter the email connected to GitHub and choose a passphrase when prompted:

#code-block("ssh-keygen -t ed25519 -C \"you@example.com\"", lang: "text")

The command above displays output similar to this. The save path and randomart may differ on your system:

+ Generating public/private ed25519 key pair.

+ Enter file in which to save the key (\~/.ssh/id\_ed25519): #emph[(Press Enter to accept the default)]

+ Enter passphrase (empty for no passphrase): #emph[(Press Enter for no passphrase)]

+ Enter same passphrase again: #emph[(Press Enter to confirm)]

#code-block("Your identification has been saved in C:\\Users\\USERNAME\\.ssh\\id_ed25519\nYour public key has been saved in C:\\Users\\USERNAME\\.ssh\\id_ed25519.pub\nThe key's randomart fingerprint is:\n+--[ED25519 256]--+\n|   ..oo+.        |\n|   o.+.= .       |\n|  . o o =        |\n|   . E o         |\n|    o . S        |\n|     o o         |\n|      o          |\n+-----------------+", lang: "text")

#strong[Load the private key into the SSH agent.] Choose the command for your operating system.

For Windows PowerShell:

#code-block("Set-Service -Name ssh-agent -StartupType Automatic\nStart-Service ssh-agent\nssh-add $env:USERPROFILE\\.ssh\\id_ed25519\ngit config --global core.sshCommand \"C:/Windows/System32/OpenSSH/ssh.exe\"", lang: "text")

For macOS: #code-block("eval \"$(ssh-agent -s)\"\nssh-add --apple-use-keychain ~/.ssh/id_ed25519", lang: "text")

For Linux: #code-block("eval \"$(ssh-agent -s)\"\nssh-add ~/.ssh/id_ed25519", lang: "text")

Copy the #emph[public] key. Never upload or share the file without `.pub`.

#code-block("# Windows PowerShell\nGet-Content $env:USERPROFILE\\.ssh\\id_ed25519.pub | Set-Clipboard\n\n# macOS\npbcopy < ~/.ssh/id_ed25519.pub\n\n# Linux: display it, then copy the complete line\ncat ~/.ssh/id_ed25519.pub", lang: "text")

To authenticate Git operations securely without entering your password, copy your public SSH key and register it in your GitHub account:

+ Copy your public key directly to your clipboard. If you generated an ed25519 key, run the command below in PowerShell or terminal. Do not share or copy the private key (`id_ed25519`).

+ In the upper-right corner of GitHub, click your profile icon and select #strong[Settings].

+ In the left sidebar under #strong[Access], select #strong[SSH and GPG keys].

+ Click #strong[New SSH key] (or #strong[Add SSH key]).

+ In the #strong[Title] field, enter a descriptive label such as `personal laptop`.

+ Ensure #strong[Key type] is set to #strong[Authentication Key].

+ Paste the public key string into the #strong[Key] field.

+ Click #strong[Add SSH key], then confirm your GitHub account password or two-factor prompt if requested.

Verify that your machine successfully connects and authenticates with GitHub:

#code-block("ssh -T git@github.com", lang: "text")
