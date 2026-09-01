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
#   1. source home-manager's session vars, so the profile's bin/ is on PATH
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
