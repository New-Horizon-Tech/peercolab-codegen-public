#!/usr/bin/env bash
#
# Installer for peercolab (PeerColab Codegen).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/New-Horizon-Tech/peercolab-codegen-public/main/install.sh | bash
#
# Environment overrides:
#   PEERCOLAB_INSTALL_DIR   Install directory (default: $HOME/.local/bin,
#                           falling back to /usr/local/bin or $HOME/.peercolab/bin).
#   PEERCOLAB_VERSION       Release tag to install (default: latest).
#

set -e

REPO="New-Horizon-Tech/peercolab-codegen-public"
VERSION="${PEERCOLAB_VERSION:-latest}"

detect_platform() {
    local os arch
    os="$(uname -s)"
    arch="$(uname -m)"
    case "$os" in
        Linux)  os="linux" ;;
        Darwin) os="osx" ;;
        *) echo "Unsupported OS: $os (use install.ps1 on Windows)." >&2; exit 1 ;;
    esac
    case "$arch" in
        x86_64|amd64) arch="x64" ;;
        arm64|aarch64) arch="arm64" ;;
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
    esac
    echo "${os}-${arch}"
}

download() {
    local url="$1" out="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$out"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$out" "$url"
    else
        echo "curl or wget is required." >&2
        exit 1
    fi
}

path_contains() {
    case ":$PATH:" in
        *":$1:"*) return 0 ;;
        *) return 1 ;;
    esac
}

pick_install_dir() {
    if [ -n "$PEERCOLAB_INSTALL_DIR" ]; then
        echo "$PEERCOLAB_INSTALL_DIR"
        return
    fi
    if path_contains "$HOME/.local/bin" || [ -d "$HOME/.local/bin" ]; then
        echo "$HOME/.local/bin"
        return
    fi
    if [ -w /usr/local/bin ] && path_contains "/usr/local/bin"; then
        echo "/usr/local/bin"
        return
    fi
    echo "$HOME/.peercolab/bin"
}

PLATFORM="$(detect_platform)"
ASSET="peercolab-${PLATFORM}"

if [ "$VERSION" = "latest" ]; then
    URL="https://github.com/${REPO}/releases/latest/download/${ASSET}"
else
    URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET}"
fi

INSTALL_DIR="$(pick_install_dir)"
TARGET="${INSTALL_DIR}/peercolab"

echo "Installing peercolab (${PLATFORM}) to ${TARGET}"

mkdir -p "$INSTALL_DIR"

TMP="$(mktemp -t peercolab.XXXXXX)"
trap 'rm -f "$TMP"' EXIT

echo "Downloading ${URL}"
download "$URL" "$TMP"

chmod +x "$TMP"

# Clear macOS quarantine if present, so Gatekeeper doesn't block the first launch.
if [ "${PLATFORM%-*}" = "osx" ] && command -v xattr >/dev/null 2>&1; then
    xattr -d com.apple.quarantine "$TMP" 2>/dev/null || true
fi

mv -f "$TMP" "$TARGET"
trap - EXIT

echo "Installed: $TARGET"

if path_contains "$INSTALL_DIR"; then
    echo
    echo "Run: peercolab"
else
    echo
    echo "NOTE: $INSTALL_DIR is not on your PATH."
    echo "      Add this line to your shell rc (~/.bashrc, ~/.zshrc, etc.):"
    echo
    echo "        export PATH=\"\$PATH:$INSTALL_DIR\""
    echo
    echo "      Or run peercolab directly via: $TARGET"
fi
