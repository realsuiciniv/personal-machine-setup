{
  description = "Per-project Node dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      # Read the major version from .nvmrc, tolerating leading "v", trailing
      # newlines, and extra whitespace. Nix's regex `.` does not match newline,
      # so strip whitespace before matching.
      major =
        if builtins.pathExists ./.nvmrc
        then
          let
            raw = builtins.readFile ./.nvmrc;
            clean = builtins.replaceStrings
              [ "\n" "\r" " " "\t" "v" "V" ] [ "" "" "" "" "" "" ] raw;
            m = builtins.match "([0-9]+).*" clean;
          in
            if m != null then builtins.head m else "20"
        else "20";

      node = pkgs."nodejs_${major}";
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ node pkgs.pnpm pkgs.bun ];
      };
    };
}
