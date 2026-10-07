{ config, pkgs, lib, ... }:
let
  dot = "${config.home.homeDirectory}/dotfiles";
  prefix = config.dotfiles.tmux.prefix;
in
{
  # tmux.conf is symlinked out-of-store and shared by every config, so the
  # per-config prefix lives in a generated file that tmux.conf sources.
  options.dotfiles.tmux.prefix = lib.mkOption {
    type = lib.types.str;
    default = "C-b";
    description = "tmux prefix key, in tmux key notation (e.g. C-a).";
  };

  config = {
    home.packages = [ pkgs.tmux ];

    home.file.".tmux.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${dot}/modules/tmux.conf";

    home.file.".config/tmux/prefix.conf".text = ''
      unbind C-b
      set -g prefix ${prefix}
      bind ${prefix} send-prefix
    '';

    home.activation.installTpm = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        ${pkgs.git}/bin/git clone \
          https://github.com/tmux-plugins/tpm \
          "$HOME/.tmux/plugins/tpm"
      fi
    '';
  };
}
