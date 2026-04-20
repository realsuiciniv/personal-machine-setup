{
  description = "Per-project Python dev shell (python + uv)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      # Read major.minor from .python-version if present (e.g., "3.12" or "3.12.5").
      # Nix's regex `.` does not match newline, so strip whitespace first.
      pythonAttr =
        if builtins.pathExists ./.python-version
        then
          let
            raw = builtins.readFile ./.python-version;
            clean = builtins.replaceStrings
              [ "\n" "\r" " " "\t" ] [ "" "" "" "" ] raw;
            m = builtins.match "([0-9]+)\\.([0-9]+).*" clean;
          in
            if m != null
            then "python${builtins.elemAt m 0}${builtins.elemAt m 1}"
            else "python314"
        else "python314";

      python = pkgs.${pythonAttr};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ python pkgs.uv ];
      };
    };
}
