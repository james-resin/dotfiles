# Home-manager only wires PATH into shells it owns via programs.<shell>.enable
# (here, just zsh). On boxes where the login shell is bash -- e.g. shared
# eval machines with a conda-managed ~/.bashrc, where we don't have root to
# chsh -- nothing from the home-manager profile (nvim, claude, fzf, zsh
# itself, ...) ever reaches PATH, and there's no root-free way to make zsh
# the login shell.
#
# Rather than enabling programs.bash (which would make home-manager own
# ~/.bashrc outright and clobber conda's init block), append two guarded
# blocks that leave the rest of the file alone:
#   1. put ~/.nix-profile/bin on PATH directly. NOTE: this is deliberately
#      NOT done by sourcing hm-session-vars.sh -- that file only carries
#      misc exports (locale, starship config) and does not touch PATH.
#      PATH normally reaches bash via a system-wide /etc/profile.d/nix*.sh
#      the installer sets up, but that's flaky across distros/install modes
#      (e.g. multi-user installs where /etc/profile.d isn't sourced for
#      some shell invocations), so just set it ourselves unconditionally.
#   2. once that's true, exec into zsh for interactive shells -- the
#      root-free equivalent of chsh, since chsh needs the shell listed in
#      /etc/shells, which requires root to edit.
#
# Applied to both ~/.bashrc and ~/.profile: which one bash reads depends on
# how the shell was invoked (non-login interactive shells -- new terminals,
# tmux panes -- read ~/.bashrc; login shells read ~/.profile, or
# ~/.bash_profile/~/.bash_login if present instead), and that's invocation
# type, not something we control, so cover both.
{ lib, ... }:
{
  home.activation.bashSessionVars = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for RCFILE in "$HOME/.bashrc" "$HOME/.profile"; do
      [[ -e "$RCFILE" ]] || touch "$RCFILE"

      SESSION_VARS_MARKER="# home-manager session vars"
      if ! grep -qF "$SESSION_VARS_MARKER" "$RCFILE"; then
        {
          echo ""
          echo "$SESSION_VARS_MARKER"
          echo '[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"'
        } >> "$RCFILE"
      fi

      # Separate marker from the block above: hm-session-vars.sh doesn't
      # touch PATH, so this needs to always run even on rc files that
      # already have the (now insufficient) session-vars block appended.
      NIX_PATH_MARKER="# ensure ~/.nix-profile/bin is on PATH"
      if ! grep -qF "$NIX_PATH_MARKER" "$RCFILE"; then
        {
          echo ""
          echo "$NIX_PATH_MARKER"
          echo 'case ":$PATH:" in'
          echo '  *":$HOME/.nix-profile/bin:"*) ;;'
          echo '  *) export PATH="$HOME/.nix-profile/bin:$PATH" ;;'
          echo 'esac'
        } >> "$RCFILE"
      fi

      EXEC_ZSH_MARKER="# hand off interactive shells to zsh (root-free chsh)"
      if ! grep -qF "$EXEC_ZSH_MARKER" "$RCFILE"; then
        {
          echo ""
          echo "$EXEC_ZSH_MARKER"
          echo 'case $- in'
          echo '  *i*) [[ -z "$ZSH_VERSION" ]] && command -v zsh >/dev/null 2>&1 && exec zsh -l ;;'
          echo 'esac'
        } >> "$RCFILE"
      fi
    done
  '';
}
