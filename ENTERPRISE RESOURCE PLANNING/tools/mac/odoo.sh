#!/bin/sh
# macOS launcher, for Intel and Apple Silicon Macs.
# Run "sh tools/mac/odoo.sh" for the menu, or: sh tools/mac/odoo.sh setup
# Needs nothing installed: curl, tar and shasum come with macOS. On the first run it
# downloads a private Python into tools/mac/runtime.

# The tools that come with macOS first, so that Anaconda's or Homebrew's cannot interfere.
PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH

if [ "$(uname -s)" != "Darwin" ]; then
    echo "This folder is for macOS. For Linux use tools/linux, and for Windows tools/windows."
    exit 1
fi

tools=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
runtime="$tools/runtime"
python="$runtime/python/bin/python3"
cd "$tools/../.." || exit 1

bootstrap() {
    release="https://github.com/astral-sh/python-build-standalone/releases/download/20261026"
    # Asks for the Mac's real chip. uname -m would say x86_64 on Apple Silicon if this
    # shell is running under Rosetta, and the slower Intel builds would be downloaded.
    if [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = "1" ]; then
        name="aarch64-apple-darwin"
        sha="fbf4afef53c2a6b72bb741bc06d5671a9dfaf87bd84e5aa73ac9b3d0d589f14e"
    else
        name="x86_64-apple-darwin"
        sha="a962e47df522889eaa7ff0d6a56203f1079f68aabb65ffdbe8455f362bc769f3"
    fi
    url="$release/cpython-3.12.16+20261026-$name-install_only.tar.gz"
    archive="$runtime/python-download.tar.gz"
    unpack="$runtime/python-unpack"

    echo
    echo "First run: downloading Python 3.12 into the tools folder."
    echo "It stays in that folder. Nothing is installed on this computer."
    echo
    mkdir -p "$runtime" || return 1

    curl -fL --retry 3 --progress-bar -o "$archive" "$url" || { echo "Python could not be downloaded. Check your internet connection."; return 1; }

    actual=$(shasum -a 256 "$archive" | cut -d' ' -f1)
    if [ "$actual" != "$sha" ]; then
        rm -f "$archive"
        echo "The download did not match its expected checksum, so it was not used."
        return 1
    fi

    rm -rf "$unpack"
    mkdir -p "$unpack"
    tar -xzf "$archive" -C "$unpack" || { echo "Python could not be unpacked. Delete tools/mac/runtime and try again."; return 1; }
    mv "$unpack/python" "$runtime/python" || return 1
    rm -rf "$unpack" "$archive"
}

if [ ! -x "$python" ]; then
    bootstrap || exit 1
fi

# A runtime brought from another Mac, such as an Intel one, may not run on this one.
if ! "$python" -I -c "" 2>/dev/null; then
    echo "The private Python will not run on this Mac. It may have come from a different type of Mac."
    echo "Delete tools/mac/runtime and try again. Your lab work in tools/mac/data is kept."
    exit 1
fi

exec "$python" -I "$tools/setup_odoo.py" "$@"
