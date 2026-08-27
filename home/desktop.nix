# Desktop additions on top of base.nix: GNOME session (narsil), terminal.
# GNOME itself (the session, GDM/SDDM session entry, portals) is enabled at
# the NixOS level in the nix repo -- this only adds home-manager-level
# packages/config for the GNOME desktop.
{ ... }:
{
  imports = [
    ./base.nix
    ../modules/ghostty.nix
    ../modules/gnome.nix
  ];
}
