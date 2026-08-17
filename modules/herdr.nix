{ pkgs, lib, ... }:

let
  version = "0.8.0";

  # Prebuilt release binaries. herdr's flake builds libghostty-vt from source
  # via zig, which needs the macOS SDK and fails in the nix sandbox
  # (DarwinSdkNotFound), so we install the upstream binary directly instead.
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
      sha256 = "0y41cnn89ggz13sws2wrlw5dsnig018vy9r9cdawrpygzj9ryfnm";
    };
    "x86_64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-x86_64";
      sha256 = "0jfng2xv1acagw6y5540s0d362f207n79r18pkrsmjlgdkymmjvp";
    };
    "aarch64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-aarch64";
      sha256 = "11yalf10vz4d03y0c5k4c3m0m3s6hjr4ylzy8b3gp7ld8rkaqizn";
    };
    "x86_64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
      sha256 = "0a6dk9p5zczmyg9ga8n60fsbfvgj3cmvdjbshmzb2b7s81zflwmq";
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
