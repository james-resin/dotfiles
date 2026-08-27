{ config, pkgs, ... }:
let dot = "${config.home.homeDirectory}/dotfiles"; in
{
  home.packages = [ pkgs.ghostty ];

  xdg.configFile."ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dot}/modules/ghostty";
}
