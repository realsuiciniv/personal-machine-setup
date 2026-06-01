{ pkgs, lib, ... }:

let
  version = "0.6.6";

  # Prebuilt release binaries. herdr's flake builds libghostty-vt from source
  # via zig, which needs the macOS SDK and fails in the nix sandbox
  # (DarwinSdkNotFound), so we install the upstream binary directly instead.
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
      sha256 = "0gvcbsz5n0ri6crpy9bwyx4ny1k1zc29hqaipidhinvlmiyghdsl";
    };
    "x86_64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-x86_64";
      sha256 = "1ib7pfd82z4j81azq4k6kw9vjydsrbm6aq0qi5yjp3zrpbl8w1zm";
    };
    "aarch64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-aarch64";
      sha256 = "1lhn7pim2pq1s14kjkzb79n8yy14llp385yfr0k6w0ci05fkg0k9";
    };
    "x86_64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
      sha256 = "1b7aq05x61hcqk8hxhd44zbvlqqlz7wmjwhdcfryyd4l8qwhl30d";
    };
  };

  source = sources.${pkgs.stdenv.hostPlatform.system}
    or (throw "herdr: unsupported platform ${pkgs.stdenv.hostPlatform.system}");

  herdr = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr";
    inherit version;

    src = pkgs.fetchurl source;

    dontUnpack = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/herdr
      runHook postInstall
    '';

    meta = with lib; {
      description = "Terminal-native runtime for managing multiple AI coding agents in one session";
      homepage = "https://herdr.dev";
      license = licenses.mit;
      platforms = builtins.attrNames sources;
      mainProgram = "herdr";
    };
  };
in
{
  home.packages = [ herdr ];
}
