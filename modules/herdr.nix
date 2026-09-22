{ pkgs, lib, ... }:

let
  version = "0.9.1";

  # Prebuilt release binaries. herdr's flake builds libghostty-vt from source
  # via zig, which needs the macOS SDK and fails in the nix sandbox
  # (DarwinSdkNotFound), so we install the upstream binary directly instead.
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
      sha256 = "1pl97hqs421drswqb0mbilk5fcv94nqdr2dah3x5djpsmpksgisz";
    };
    "x86_64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-x86_64";
      sha256 = "150yrqmr3mlbr19k3d55afkzdr2l21jldnzvbsmm9zimk5iy0fq5";
    };
    "aarch64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-aarch64";
      sha256 = "17ldpldp5ayf4qqaipjq5bn51b9xf2irnglqkaivjb2zfkgg9k7l";
    };
    "x86_64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
      sha256 = "1dslbhymcl24sk93q1ddb3fa8b35iw23zm710vq1wrgbdg8zw0ia";
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

  # Vendored herdr config. herdr writes session.json / sockets / logs into
  # ~/.config/herdr at runtime, but config.toml itself is read-only to herdr,
  # so a managed symlink is safe. Edit the source in dotfiles/ and re-switch.
  xdg.configFile."herdr/config.toml".source = ../dotfiles/herdr/config.toml;
}
