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
        overlays = [
          # pipx 1.8.0 in current nixpkgs fails its test suite on darwin
          # (packaging PEP 508 normalization mismatch). Skip the tests.
          (final: prev: {
            pipx = prev.pipx.overridePythonAttrs (_: {
              doCheck = false;
              doInstallCheck = false;
            });
          })
        ];
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
        python = {
          path = ./templates/python;
          description = "Python dev shell; reads major.minor from .python-version if present; uv for deps";
        };
      };
    };
}
