{
  description = "Per-project Node dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      major =
        if builtins.pathExists ./.nvmrc
        then builtins.head (builtins.match "v?([0-9]+).*" (builtins.readFile ./.nvmrc))
        else "20";

      node = pkgs."nodejs_${major}";
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ node pkgs.pnpm pkgs.bun ];
      };
    };
}
