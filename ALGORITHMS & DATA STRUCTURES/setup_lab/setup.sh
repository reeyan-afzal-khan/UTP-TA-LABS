#!/usr/bin/env sh
# ============================================================================
#  Algorithms & Data Structures: lab setup for Linux and macOS
#
#  Run it from a terminal; it asks for your password only to install software:
#    sh setup.sh                    install what is missing; create ~/UTP-ADS
#    sh setup.sh ~/uni/UTP-ADS      the same, with a project folder of your choice
#    sh setup.sh --check            report what is installed; change nothing
#    sh setup.sh --no-install       install no software; set up the project only
#    sh setup.sh --no-open          do not open VS Code at the end
#    sh setup.sh --yes              do not ask before installing
#
#  It installs only what is missing, and asks before it starts:
#    Linux   g++ and gdb, with apt, dnf, pacman or zypper
#    macOS   Apple's Command Line Tools: clang++ and lldb
#    both    Microsoft's C/C++ extension for VS Code, and VS Code itself
#            where it can (Homebrew on macOS, snap on Linux)
#  It copies the VS Code settings from the vscode folder into the project and
#  builds check_setup.cpp to prove that everything works. Run it again whenever
#  you like: whatever is already in place is left as it is.
# ============================================================================
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT="$HOME/UTP-ADS"
MODE=setup
INSTALL=1
OPEN=1
ASK=1

usage() {
    cat <<'EOF'
Usage: sh setup.sh [folder] [--check] [--no-install] [--no-open] [--yes]

  folder         where to create your lab project (default: ~/UTP-ADS)
  --check        report what is installed and build the test program; change nothing
  --no-install   install no software; set up the project folder only
  --no-open      do not open VS Code at the end
  --yes          do not ask before installing
EOF
}

while [ $# -gt 0 ]; do
    case $1 in
        --check) MODE=check ;;
        --no-install) INSTALL=0 ;;
        --no-open) OPEN=0 ;;
        --yes) ASK=0 ;;
        -h | --help) usage; exit 0 ;;
        -*) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
        *) PROJECT=$1 ;;
    esac
    shift
done
case $PROJECT in
    /*) ;;
    *) PROJECT="$(pwd)/$PROJECT" ;;
esac

case $(uname -s) in
    Darwin) OS=macos ;;
    Linux) OS=linux ;;
    *) echo "This script is for Linux and macOS. On Windows, run setup.bat instead." >&2; exit 1 ;;
esac
WSL=0
if [ "$OS" = linux ] && grep -qi microsoft /proc/version 2>/dev/null; then
    WSL=1
fi

say() { printf '%s\n' "$*"; }
row() { printf '   %-19s%s\n' "$1" "$2"; }

# Run a command as root: directly when already root, otherwise through sudo.
as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        say "       This step needs administrator rights, and sudo is not available: $*"
        return 1
    fi
}

# Find the compiler, debugger, VS Code and its C/C++ extension.
detect() {
    CXX=""
    DBG=""
    CODE=""
    CPPTOOLS=0
    if [ "$OS" = macos ]; then
        if xcode-select -p >/dev/null 2>&1; then
            CXX=$(command -v clang++ 2>/dev/null || true)
            DBG=$(command -v lldb 2>/dev/null || true)
        fi
    else
        CXX=$(command -v g++ 2>/dev/null || true)
        DBG=$(command -v gdb 2>/dev/null || true)
    fi
    CODE=$(command -v code 2>/dev/null || true)
    if [ -z "$CODE" ]; then
        for candidate in "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
            "$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
            /snap/bin/code /usr/bin/code /usr/share/code/bin/code; do
            if [ -x "$candidate" ]; then
                CODE=$candidate
                break
            fi
        done
    fi
    CXX_TEXT="not found"
    DBG_TEXT="not found"
    CODE_TEXT="not found"
    EXT_TEXT="not installed"
    if [ -n "$CXX" ]; then
        if [ "$OS" = macos ]; then
            CXX_TEXT="$("$CXX" --version 2>/dev/null | head -n 1)   $CXX"
        else
            CXX_TEXT="g++ $("$CXX" -dumpfullversion 2>/dev/null || "$CXX" -dumpversion 2>/dev/null || true)   $CXX"
        fi
    fi
    if [ -n "$DBG" ]; then
        DBG_TEXT=$DBG
    fi
    if [ -n "$CODE" ]; then
        CODE_TEXT=$("$CODE" --version 2>/dev/null | head -n 1 || true)
        if "$CODE" --list-extensions 2>/dev/null | grep -qix 'ms-vscode.cpptools'; then
            CPPTOOLS=1
            EXT_TEXT=installed
        fi
    fi
}

install_compiler() {
    if [ "$OS" = macos ]; then
        xcode-select --install >/dev/null 2>&1 || true
        say "       A window has opened to install Apple's Command Line Tools."
        say "       Click Install and wait until it finishes. (Ctrl+C stops waiting.)"
        waited=0
        until xcode-select -p >/dev/null 2>&1; do
            if [ "$waited" -ge 1800 ]; then
                say "       Still not installed after 30 minutes. Run this script again when it is."
                return 1
            fi
            sleep 10
            waited=$((waited + 10))
        done
        return 0
    fi
    if command -v apt-get >/dev/null 2>&1; then
        as_root apt-get update && as_root apt-get install -y g++ gdb
    elif command -v dnf >/dev/null 2>&1; then
        as_root dnf install -y gcc-c++ gdb
    elif command -v pacman >/dev/null 2>&1; then
        as_root pacman -S --needed --noconfirm gcc gdb
    elif command -v zypper >/dev/null 2>&1; then
        as_root zypper --non-interactive install gcc-c++ gdb
    else
        say "       No apt, dnf, pacman or zypper here. Install g++ and gdb with your"
        say "       package manager, then run this script again."
        return 1
    fi
}

install_code() {
    if [ "$OS" = macos ]; then
        if command -v brew >/dev/null 2>&1; then
            brew install --cask visual-studio-code
            return
        fi
        say "       Download VS Code from https://code.visualstudio.com, move it to Applications,"
        say "       open it once, then run this script again."
        return 1
    fi
    if [ "$WSL" = 1 ]; then
        say "       In WSL, use the VS Code installed on Windows: install it there with its"
        say "       WSL extension, run 'code .' here once, then run this script again."
        return 1
    fi
    if command -v snap >/dev/null 2>&1; then
        as_root snap install code --classic
        return
    fi
    say "       Install VS Code from https://code.visualstudio.com/download (.deb or .rpm),"
    say "       then run this script again."
    return 1
}

# Build and run check_setup.cpp with the compiler that was found.
verify() {
    say ""
    if [ -z "$CXX" ]; then
        say " No C++ compiler was found, so nothing could be built. Run sh setup.sh without"
        say " --check or --no-install to install one."
        return 1
    fi
    say " Check: building and running check_setup.cpp"
    tmp=$(mktemp -d 2>/dev/null || mktemp -d -t utp-ads)
    if "$CXX" -std=c++17 -Wall -Wextra -pedantic "$HERE/check_setup.cpp" -o "$tmp/check_setup" &&
        "$tmp/check_setup"; then
        rm -rf "$tmp"
        return 0
    fi
    rm -rf "$tmp"
    say ""
    say " The test program did not build or run. Read the messages above, then see"
    say " \"If something goes wrong\" in setup_lab/README.md."
    return 1
}

say ""
say " Algorithms & Data Structures - lab setup"
say " ----------------------------------------"
if [ ! -f "$HERE/vscode/tasks.json" ] || [ ! -f "$HERE/check_setup.cpp" ]; then
    say " This script needs the files next to it: check_setup.cpp and the vscode folder."
    say " Run it from inside the setup_lab folder of the course."
    exit 1
fi
if [ "$(id -u)" -eq 0 ] && [ "$MODE" = setup ]; then
    say " You are running this as root. Run it as yourself instead (without sudo):"
    say " it asks for your password when it installs something."
fi

detect
say ""
say " Found on this computer"
row "C++ compiler" "$CXX_TEXT"
row "Debugger" "$DBG_TEXT"
row "VS Code" "$CODE_TEXT"
row "C/C++ extension" "$EXT_TEXT"
row "Project folder" "$PROJECT"

if [ "$MODE" = check ]; then
    if verify; then exit 0; else exit 1; fi
fi

# ------------------------------------------------------------------ the plan
NEED_CXX=0
NEED_CODE=0
NEED_EXT=0
if [ -z "$CXX" ] || [ -z "$DBG" ]; then NEED_CXX=1; fi
if [ -z "$CODE" ]; then NEED_CODE=1; fi
if [ "$CPPTOOLS" = 0 ]; then NEED_EXT=1; fi
if [ "$INSTALL" = 0 ]; then
    say ""
    say " --no-install: nothing will be installed."
elif [ $((NEED_CXX + NEED_CODE + NEED_EXT)) -gt 0 ]; then
    say ""
    say " To finish, this script will install:"
    if [ "$NEED_CXX" = 1 ] && [ "$OS" = macos ]; then
        say "   - Apple's Command Line Tools: clang++ and lldb"
    elif [ "$NEED_CXX" = 1 ]; then
        say "   - g++ and gdb, with your package manager (it asks for your password)"
    fi
    if [ "$NEED_CODE" = 1 ]; then say "   - Visual Studio Code, where this system allows it"; fi
    if [ "$NEED_EXT" = 1 ]; then say "   - Microsoft's C/C++ extension for VS Code"; fi
    if [ "$ASK" = 1 ]; then
        say ""
        printf ' Press Enter to start, or Ctrl+C to cancel. '
        read -r _ || true
    fi
fi

# --------------------------------------------------- 1. compiler and debugger
say ""
say " [1/3] Compiler and debugger"
if [ "$INSTALL" = 1 ] && [ "$NEED_CXX" = 1 ]; then
    if ! install_compiler; then
        say "       The compiler was not installed."
    fi
    detect
fi
say "       $CXX_TEXT"
say "       debugger: $DBG_TEXT"

# ------------------------------------------------- 2. VS Code and extension
say ""
say " [2/3] VS Code"
if [ "$INSTALL" = 1 ]; then
    if [ -z "$CODE" ]; then
        if install_code; then detect; fi
    fi
    if [ -n "$CODE" ] && [ "$CPPTOOLS" = 0 ]; then
        "$CODE" --install-extension ms-vscode.cpptools || true
        detect
    fi
fi
if [ -z "$CODE" ]; then
    say "       VS Code not found"
elif [ "$CPPTOOLS" = 1 ]; then
    say "       VS Code $CODE_TEXT with the C/C++ extension"
else
    say "       VS Code $CODE_TEXT, without the C/C++ extension"
fi

# ---------------------------------------------------------- 3. project folder
say ""
say " [3/3] Project folder"
if ! mkdir -p "$PROJECT/.vscode" 2>/dev/null; then
    say "       Could not create $PROJECT. Choose a folder you can write to:"
    say "       sh setup.sh ~/UTP-ADS"
    exit 1
fi
n=1
while [ "$n" -le 11 ]; do
    mkdir -p "$PROJECT/$(printf 'Lab%02d' "$n")"
    n=$((n + 1))
done
# A settings file you changed is kept beside the new one, with .bak added.
for source in "$HERE"/vscode/*.json; do
    name=$(basename "$source")
    target="$PROJECT/.vscode/$name"
    if [ -f "$target" ]; then
        if cmp -s "$source" "$target"; then continue; fi
        cp "$target" "$target.bak"
        say "       kept your previous $name as $name.bak"
    fi
    cp "$source" "$target"
done
if [ ! -f "$PROJECT/README.md" ]; then cp "$HERE/project/README.md" "$PROJECT/README.md"; fi
if [ ! -f "$PROJECT/.gitignore" ]; then cp "$HERE/project/gitignore" "$PROJECT/.gitignore"; fi
say "       $PROJECT"
say "       Lab01 to Lab11, .vscode settings, README.md and .gitignore"

# ------------------------------------------------------------------ the check
if ! verify; then exit 1; fi
if [ "$OPEN" = 1 ] && [ -n "$CODE" ]; then
    if [ "$OS" = macos ] || [ "$WSL" = 1 ] || [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
        "$CODE" "$PROJECT" >/dev/null 2>&1 || true
    fi
fi
say ""
say " Ready. In VS Code, open a .cpp file in your project folder, then press"
if [ "$OS" = macos ]; then
    say " Cmd+Shift+B to build and run it, or F5 to run it in the debugger."
else
    say " Ctrl+Shift+B to build and run it, or F5 to run it in the debugger."
fi
if [ -z "$CODE" ]; then
    say " Install VS Code from https://code.visualstudio.com, then run this script again."
fi
