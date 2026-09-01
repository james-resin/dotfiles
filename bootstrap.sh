#!/usr/bin/env bash
# Bootstrap Nix + home-manager for these dotfiles.
# Assumes this repo is already cloned. Usage: ./bootstrap.sh [desktop|headless]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${1:-headless}"

if ! command -v nix >/dev/null 2>&1; then
    echo "==> nix not on PATH in this shell; installing/checking via Determinate Systems installer"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

    # The installer may report an already-completed install (e.g. baked into
    # the image, or installed by someone else) without touching this shell's
    # PATH. Rather than guess which profile-script filename applies, just
    # prepend the known bin dirs directly.
    for bindir in /nix/var/nix/profiles/default/bin "$HOME/.nix-profile/bin"; do
        if [[ -d "$bindir" ]]; then
            PATH="$bindir:$PATH"
        fi
    done

    if ! command -v nix >/dev/null 2>&1; then
        echo "nix still not found on PATH after install. Open a new shell (so /etc/bashrc or /etc/zshrc can pick it up) and re-run this script." >&2
        exit 1
    fi
else
    echo "==> Nix already on PATH, skipping install"
fi

echo "==> Activating home-manager config '$CONFIG' from $SCRIPT_DIR"

IMPURE_FLAG=()
if [[ "$CONFIG" == "headless" ]]; then
    IMPURE_FLAG=(--impure)
fi

nix run home-manager/master -- switch --flake "$SCRIPT_DIR#$CONFIG" "${IMPURE_FLAG[@]}" -b bak

echo "==> Done. Future activations: home-manager switch --flake $SCRIPT_DIR#$CONFIG -b bak"
