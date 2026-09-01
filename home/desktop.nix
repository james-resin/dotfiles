# Desktop additions on top of base.nix: GNOME session, terminal.
# GNOME itself (the session, GDM/SDDM session entry, portals) is enabled at
# the NixOS level in the nix repo -- this only adds home-manager-level
# packages/config for the GNOME desktop.
{ inputs, pkgs, ... }:
{
  imports = [
    ./base.nix
    ../modules/ghostty.nix
    ../modules/gnome.nix
  ];

  home.packages = with pkgs; [
    slack
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    zoom-us
  ];
}
