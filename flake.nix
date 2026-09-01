{
  description = "Work dotfiles, managed as a home-manager flake (narsil, GNOME)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
	zen-browser = {
	  url = "github:youwen5/zen-browser-flake";
	  inputs.nixpkgs.follows = "nixpkgs";
	};
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};

    # This machine, known ahead of time -- kept as literals so evaluating
    # this configuration doesn't require --impure.
    identity = {
      home.username      = "work";
      home.homeDirectory = "/home/work";
    };

    # Meant to be deployed onto whatever VM/server, under whatever user
    # is doing the deploying -- read from the environment instead, which
    # means building this configuration needs `nix build --impure`.
    portableIdentity = {
      home.username      = builtins.getEnv "USER";
      home.homeDirectory = builtins.getEnv "HOME";
    };

    mkHome = identityModule: extraModules: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [ identityModule ] ++ extraModules;
    };
  in {
    homeConfigurations.desktop = mkHome identity [
      ./home/desktop.nix
    ];

    homeConfigurations.headless = mkHome portableIdentity [
      ./home/base.nix
    ];
  };
}
