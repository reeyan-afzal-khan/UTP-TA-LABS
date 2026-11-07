#!/bin/sh
# Linux launcher. Run "sh tools/linux/odoo.sh" for the menu, or: sh tools/linux/odoo.sh setup
# Needs nothing installed beyond curl or wget, and tar: on the first run it downloads a
# private Python into tools/linux/runtime.
tools=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
runtime="$tools/runtime"
python="$runtime/python/bin/python3"
cd "$tools/../.." || exit 1

bootstrap() {
    release="https://github.com/astral-sh/python-build-standalone/releases/download/20261026"
    case "$(uname -s)-$(uname -m)" in
        Linux-x86_64)
            name="x86_64-unknown-linux-gnu"
            sha="6a79e922e50006b601f29e688407659da1c2b86ebcd4e9c7254cf234be8b89de" ;;
        Linux-aarch64)
            name="aarch64-unknown-linux-gnu"
            sha="a945427411dc6851a1393533b74a4a1ac434321ae397f2ec69897a9b4fde032b" ;;
        *)
            echo "There is no ready-made Python here for $(uname -s) $(uname -m)."
            echo "This folder is for Linux. For a Mac use tools/mac, and for Windows tools/windows."
            return 1 ;;
    esac
    url="$release/cpython-3.12.16+20261026-$name-install_only.tar.gz"
    archive="$runtime/python-download.tar.gz"
    unpack="$runtime/python-unpack"

    echo
    echo "First run: downloading Python 3.12 into the tools folder."
    echo "It stays in that folder. Nothing is installed on this computer."
    echo
    mkdir -p "$runtime" || return 1

    if command -v curl >/dev/null 2>&1; then
        curl -fL --retry 3 --progress-bar -o "$archive" "$url" || { echo "Python could not be downloaded. Check your internet connection."; return 1; }
    elif command -v wget >/dev/null 2>&1; then
        wget -q --show-progress -O "$archive" "$url" || { echo "Python could not be downloaded. Check your internet connection."; return 1; }
    else
        echo "This needs curl or wget to download Python. Install one, then try again:"
        echo "  sudo apt-get install -y curl"
        return 1
    fi

    if command -v sha256sum >/dev/null 2>&1; then
        actual=$(sha256sum "$archive" | cut -d' ' -f1)
    else
        actual=$(shasum -a 256 "$archive" | cut -d' ' -f1)
    fi
    if [ "$actual" != "$sha" ]; then
        rm -f "$archive"
        echo "The download did not match its expected checksum, so it was not used."
        return 1
    fi

    rm -rf "$unpack"
    mkdir -p "$unpack"
    tar -xzf "$archive" -C "$unpack" || { echo "Python could not be unpacked. Delete tools/linux/runtime and try again."; return 1; }
    mv "$unpack/python" "$runtime/python" || return 1
    rm -rf "$unpack" "$archive"
}

if [ ! -x "$python" ]; then
    bootstrap || exit 1
fi

exec "$python" -I "$tools/setup_odoo.py" "$@"
