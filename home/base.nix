# Headless-safe base: dev environment only, no GUI packages.
{ ... }:
{
  nixpkgs.config.allowUnfree = true;

  # Installs the `home-manager` command itself, so after the first
  # activation `home-manager switch` works without the flake-run dance.
  programs.home-manager.enable = true;

  imports = [
    ../modules/fonts.nix
    ../modules/git.nix
    ../modules/zsh.nix
    ../modules/tmux.nix
    ../modules/cli.nix
    ../modules/nvim.nix
  ];

  home.stateVersion = "26.05";
}
