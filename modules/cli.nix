{ config, pkgs, ... }:
let dot = "${config.home.homeDirectory}/dotfiles"; in
{
  home.packages = with pkgs; [
    eza
    fd
    bat
    ripgrep
    fastfetch
    zip
    unzip
    gnutar
    wl-clipboard
    upower
    man-pages
    man-db

    fzf
    jq
    btop
    rsync
    devenv
  ];

  home.file.".local/bin" = {
    source    = config.lib.file.mkOutOfStoreSymlink "${dot}/modules/.local/bin";
    recursive = true;
  };
}
