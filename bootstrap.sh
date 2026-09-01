#!/usr/bin/env bash
# Bootstrap Nix + home-manager for these dotfiles.
# Assumes this repo is already cloned. Usage: ./bootstrap.sh [desktop|headless]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${1:-headless}"

if ! command -v nix >/dev/null 2>&1; then
    echo "==> Installing Nix (Determinate Systems installer)"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

    # Pick up nix in this shell without requiring a new login session.
    if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    else
        echo "Could not find a nix profile script to source; open a new shell and re-run this script." >&2
        exit 1
    fi
else
    echo "==> Nix already installed, skipping"
fi

echo "==> Activating home-manager config '$CONFIG' from $SCRIPT_DIR"

IMPURE_FLAG=()
if [[ "$CONFIG" == "headless" ]]; then
    IMPURE_FLAG=(--impure)
fi

nix run home-manager/master -- switch --flake "$SCRIPT_DIR#$CONFIG" "${IMPURE_FLAG[@]}" -b bak

echo "==> Done. Future activations: home-manager switch --flake $SCRIPT_DIR#$CONFIG -b bak"
