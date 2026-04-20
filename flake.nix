{
  description = "Vinicius's personal Mac setup (home-manager standalone + sops-nix)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations."personal-laptop" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            sops-nix.homeManagerModules.sops
            ./hosts/personal-laptop
          ];
        };

      templates = {
        node = {
          path = ./templates/node;
          description = "Node dev shell; reads major version from .nvmrc if present";
        };
        java = {
          path = ./templates/java;
          description = "JVM dev shell on Temurin 25 + maven + gradle";
        };
      };
    };
}
