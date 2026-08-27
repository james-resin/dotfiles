# Minimal home-manager additions on top of the system GNOME session (see
# the nix repo's narsil host config for enabling GNOME itself). Extend this
# as GNOME customization needs grow.
#
# dconf.settings below mirrors manual tweaks made through Settings/Tweaks
# on narsil, captured via `dconf dump /`, so they survive the NixOS
# migration. Deliberately left out: window/session state (sizes,
# positions, app-picker-layout), anything auto-populated by apps
# (notification registrations, software update timestamps), and the
# desktop/screensaver background paths, which point at /usr/share and
# won't resolve the same way under NixOS.
{ lib, pkgs, ... }:
let
  inherit (lib.hm.gvariant) mkEmptyArray;

  # Matches the catppuccin-macchiato-mauve-standard+normal GTK theme this
  # machine had configured before it got reset. Only used for GTK app
  # chrome via gtk-theme below -- the bundled gnome-shell.css is NOT
  # applied (no user-theme extension). That upstream project is archived
  # and its Shell CSS predates GNOME Shell 46's popup-menu/quick-settings
  # rework, which caused overlapping/offset icons in popup menus on
  # GNOME Shell 50. Shell chrome instead relies on the native
  # accent-color/color-scheme support GNOME 46+ has built in.
  catppuccinGtkTheme = pkgs.catppuccin-gtk.override {
    accents = [ "mauve" ];
    variant = "macchiato";
    size = "standard";
    tweaks = [ "normal" ];
  };
in
{
  home.packages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager
    gnome-shell-extensions
    gnomeExtensions.just-perfection
    catppuccinGtkTheme
    papirus-icon-theme
  ];

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled = false;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "pink";
      cursor-size = 24;
      gtk-theme = "catppuccin-macchiato-mauve-standard+normal";
      icon-theme = "Papirus-Dark";
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>c" ];
      maximize = mkEmptyArray "s";
      minimize = mkEmptyArray "s";
      switch-input-source = mkEmptyArray "s";
      switch-input-source-backward = mkEmptyArray "s";
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-left = [ "<Shift><Super>h" ];
      move-to-workspace-right = [ "<Shift><Super>l" ];
      toggle-fullscreen = [ "<Super>f" ];

      # <Super>Tab cycles individual windows (MRU order) instead of
      # grouping by app; <Alt>Tab keeps the default app-switching behavior.
      switch-applications = [ "<Alt>Tab" ];
      switch-applications-backward = [ "<Shift><Alt>Tab" ];
      switch-windows = [ "<Super>Tab" ];
      switch-windows-backward = [ "<Shift><Super>Tab" ];
    };

    # <Super>h/l are freed from window-switching above so mutter can use
    # them for tiling instead.
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Super>h" ];
      toggle-tiled-right = [ "<Super>l" ];
    };

    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = mkEmptyArray "s";
      switch-to-application-2 = mkEmptyArray "s";
      switch-to-application-3 = mkEmptyArray "s";
      switch-to-application-4 = mkEmptyArray "s";

      # Ported from the Hyprland config's <Super>S region-screenshot
      # binding (closest native equivalent to `hyprshot -m region`).
      show-screenshot-ui = [ "Print" "<Super>s" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      search = [ "<Super>space" ];
      # Ported from the Hyprland config's <Super><Shift>L lock binding.
      screensaver = [ "<Shift><Super>l" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Launch Ghostty";
      command = "ghostty";
      binding = "<Super>Return";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Open Files";
      command = "nautilus";
      binding = "<Super>e";
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "just-perfection-desktop@just-perfection"
      ];
      favorite-apps = [
        "org.gnome.Calendar.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Software.desktop"
      ];
    };

    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [
        "com.mitchellh.ghostty.desktop:1"
        "zen.desktop:2"
        "slack.desktop:3"
      ];
    };

    # 2 = "top end", i.e. top-right in LTR locales. See the extension's
    # schema for the full 0-5 corner/edge mapping.
    "org/gnome/shell/extensions/just-perfection" = {
      notification-banner-position = 2;
    };
  };
}
