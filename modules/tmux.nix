{ config, pkgs, lib, ... }:
let dot = "${config.home.homeDirectory}/dotfiles"; in
{
  home.packages = [ pkgs.tmux ];

  home.file.".tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dot}/modules/tmux.conf";

  home.activation.installTpm = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
      ${pkgs.git}/bin/git clone \
        https://github.com/tmux-plugins/tpm \
        "$HOME/.tmux/plugins/tpm"
    fi
  '';
}
