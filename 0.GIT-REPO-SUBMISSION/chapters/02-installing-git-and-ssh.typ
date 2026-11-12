#import "/.shared/typst/utp.typ": *
#unit("chapters", "02-installing-git-and-ssh")

= Install Git and configure SSH <ch:git-ssh-setup>

#strong[Choose one Git installation method.] Install Git from the official website or use the terminal commands below. If Git is already installed, skip both methods and verify it with `git --version`.

=== Option 1: Install Git from the official website

#tcolorbox(back: white, frame: mix(blue, 28%), title-back: navy, rule: 0.6476pt, arc: 2mm, title: [Choose your operating system], title-color: white, left: 3.5mm, right: 3.5mm, top: 2.5mm, bottom: 2.5mm)[
  #fsize("small")[#text(fill: muted)[Follow Git’s official installation instructions for your platform.]]

  #v(3pt)
  #box(width: 32%)[
    #tcolorbox(width: 100%, height: 2.8cm, valign: horizon, back: mix(pale-blue, 35%), frame: mix(blue, 30%), rule: 0.5479pt, arc: 1.5mm, left: 1mm, right: 1mm, top: 1.5mm, bottom: 1.5mm)[
      #align(center)[#fsize-at(22.9141pt, 24.9066pt)[#text(fill: blue)[#icon-windows]]

      #v(3pt)
      #fsize("large")[#strong[#text(fill: navy)[Windows]]]

      #v(3pt)
      #link("https://git-scm.com/install/windows")[#strong[#fsize("small")[#text(fill: blue)[Installation guide $arrow.r$]]]]
      ]
    ]
  ]#h(1fr)#box(width: 32%)[
    #tcolorbox(width: 100%, height: 2.8cm, valign: horizon, back: mix(pale-blue, 35%), frame: mix(blue, 30%), rule: 0.5479pt, arc: 1.5mm, left: 1mm, right: 1mm, top: 1.5mm, bottom: 1.5mm)[
      #align(center)[#fsize-at(22.9141pt, 24.9066pt)[#text(fill: blue)[#icon-apple]]

      #v(3pt)
      #fsize("large")[#strong[#text(fill: navy)[macOS]]]

      #v(3pt)
      #link("https://git-scm.com/install/mac")[#strong[#fsize("small")[#text(fill: blue)[Installation guide $arrow.r$]]]]
      ]
    ]
  ]#h(1fr)#box(width: 32%)[
    #tcolorbox(width: 100%, height: 2.8cm, valign: horizon, back: mix(pale-blue, 35%), frame: mix(blue, 30%), rule: 0.5479pt, arc: 1.5mm, left: 1mm, right: 1mm, top: 1.5mm, bottom: 1.5mm)[
      #align(center)[#fsize-at(22.9141pt, 24.9066pt)[#text(fill: blue)[#icon-linux]]

      #v(3pt)
      #fsize("large")[#strong[#text(fill: navy)[Linux]]]

      #v(3pt)
      #link("https://git-scm.com/install/linux")[#strong[#fsize("small")[#text(fill: blue)[Installation guide $arrow.r$]]]]
      ]
    ]
  ]
]

=== Option 2: Install Git from the terminal

Use this option instead of the website instructions above. Run the command for your operating system, then reopen the terminal:

```terminal
# Windows PowerShell
winget install --id Git.Git -e --source winget

# macOS (Option A): install using Homebrew
brew install git

# macOS (Option B - If you don't have brew installed): install Apple's command-line tools
xcode-select --install

# Linux
sudo apt update
sudo apt install git
```

For SSH setup, use #strong[PowerShell] on Windows or #strong[Terminal] on macOS and Linux. The commands are labeled by platform. After either installation method, confirm Git is available:

```terminal
git --version
```

=== Configure your commit identity

Set the name and email that should appear on future commits. Use an email
connected to your GitHub account, or your GitHub-provided private email.

```terminal
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main

git config --global --list
```

#strong[Choose one SSH setup option.] Option 1 uses video walkthroughs; Option 2 provides written terminal instructions. Both cover the SSH setup, so follow the path you prefer and skip steps already completed.

=== Option 1: SSH setup with video walkthroughs

#tcolorbox(back: white, frame: mix(blue, 28%), title-back: navy, rule: 0.6476pt, arc: 2mm, title: [Choose your operating system], title-color: white, left: 3.5mm, right: 3.5mm, top: 2.5mm, bottom: 2.5mm)[
  #fsize("small")[#text(fill: muted)[Open the matching video guide for SSH setup.]]

  #v(3pt)
  #box(width: 32%)[
    #tcolorbox(width: 100%, height: 2.8cm, valign: horizon, back: mix(pale-blue, 35%), frame: mix(blue, 30%), rule: 0.5479pt, arc: 1.5mm, left: 1mm, right: 1mm, top: 1.5mm, bottom: 1.5mm)[
      #align(center)[#fsize-at(22.9141pt, 24.9066pt)[#text(fill: blue)[#icon-windows]]

      #v(3pt)
      #fsize("large")[#strong[#text(fill: navy)[Windows]]]

      #v(3pt)
      #link("https://youtu.be/YT5YimhyX18?t=5")[#strong[#fsize("small")[#text(fill: blue)[View video guide $arrow.r$]]]]
      ]
    ]
  ]#h(1fr)#box(width: 32%)[
    #tcolorbox(width: 100%, height: 2.8cm, valign: horizon, back: mix(pale-blue, 35%), frame: mix(blue, 30%), rule: 0.5479pt, arc: 1.5mm, left: 1mm, right: 1mm, top: 1.5mm, bottom: 1.5mm)[
      #align(center)[#fsize-at(22.9141pt, 24.9066pt)[#text(fill: blue)[#icon-apple]]

      #v(3pt)
      #fsize("large")[#strong[#text(fill: navy)[macOS]]]

      #v(3pt)
      #link("https://youtu.be/ACvE5Uy7ZB0?t=437")[#strong[#fsize("small")[#text(fill: blue)[View video guide $arrow.r$]]]]
      ]
    ]
  ]#h(1fr)#box(width: 32%)[
    #tcolorbox(width: 100%, height: 2.8cm, valign: horizon, back: mix(pale-blue, 35%), frame: mix(blue, 30%), rule: 0.5479pt, arc: 1.5mm, left: 1mm, right: 1mm, top: 1.5mm, bottom: 1.5mm)[
      #align(center)[#fsize-at(22.9141pt, 24.9066pt)[#text(fill: blue)[#icon-linux]]

      #v(3pt)
      #fsize("large")[#strong[#text(fill: navy)[Linux]]]

      #v(3pt)
      #link("https://youtu.be/AOM8CEyu3Ug?t=121")[#strong[#fsize("small")[#text(fill: blue)[View video guide $arrow.r$]]]]
      ]
    ]
  ]
]

=== Option 2: SSH setup from the terminal

SSH lets Git authenticate without asking for a GitHub password on every push.
The key-generation process is similar across operating systems. Use PowerShell on Windows or Terminal on macOS and Linux. The `ssh-keygen` command is the same; the commands for checking existing keys and loading them into the SSH agent are shown separately by platform.

First check whether this computer already has a key:

```terminal
# Windows PowerShell
Get-ChildItem -Force "$env:USERPROFILE\.ssh"

# macOS/Linux Terminal
ls -al ~/.ssh
```

If `id_ed25519` and `id_ed25519.pub` do not exist, create them.
Enter the email connected to GitHub and choose a passphrase when prompted:

```terminal
ssh-keygen -t ed25519 -C "you@example.com"
```

The command above displays output similar to this. The save path and randomart may differ on your system:

#listopts(leftmargin: 1.7em)[
  + Generating public/private ed25519 key pair.
  + Enter file in which to save the key (\~/.ssh/id\_ed25519): #emph[(Press Enter to accept the default)]
  + Enter passphrase (empty for no passphrase): #emph[(Press Enter for no passphrase)]
  + Enter same passphrase again: #emph[(Press Enter to confirm)]
]

```terminal
Your identification has been saved in C:\Users\USERNAME\.ssh\id_ed25519
Your public key has been saved in C:\Users\USERNAME\.ssh\id_ed25519.pub
The key's randomart fingerprint is:
+--[ED25519 256]--+
|   ..oo+.        |
|   o.+.= .       |
|  . o o =        |
|   . E o         |
|    o . S        |
|     o o         |
|      o          |
+-----------------+
```

#pagebreak()

#strong[Load the private key into the SSH agent.] Choose the command for your operating system.

For Windows PowerShell:

```terminal
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
```

For macOS:

```terminal
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

For Linux:

```terminal
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Copy the #emph[public] key. Never upload or share the file without
`.pub`.

```terminal
# Windows PowerShell
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | Set-Clipboard

# macOS
pbcopy < ~/.ssh/id_ed25519.pub

# Linux: display it, then copy the complete line
cat ~/.ssh/id_ed25519.pub
```

To authenticate Git operations securely without entering your password, copy your public SSH key and register it in your GitHub account:

#listopts(leftmargin: 1.7em)[
  + Copy your public key directly to your clipboard. If you generated an ed25519 key, run the command below in PowerShell or terminal. Do not share or copy the private key (`id_ed25519`).
  + In the upper-right corner of GitHub, click your profile icon and select #strong[Settings].
  + In the left sidebar under #strong[Access], select #strong[SSH and GPG keys].
  + Click #strong[New SSH key] (or #strong[Add SSH key]).
  + In the #strong[Title] field, enter a descriptive label such as `personal laptop`.
  + Ensure #strong[Key type] is set to #strong[Authentication Key].
  + Paste the public key string into the #strong[Key] field.
  + Click #strong[Add SSH key], then confirm your GitHub account password or two-factor prompt if requested.
]

Verify that your machine successfully connects and authenticates with GitHub:

```terminal
ssh -T git@github.com
```
