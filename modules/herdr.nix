{ pkgs, lib, ... }:

let
  version = "0.9.0";

  # Prebuilt release binaries. herdr's flake builds libghostty-vt from source
  # via zig, which needs the macOS SDK and fails in the nix sandbox
  # (DarwinSdkNotFound), so we install the upstream binary directly instead.
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
      sha256 = "05zg386gfqrl3x112rzjvla9xqmqlq19z9l9qxcq0qkjk3q3vd9j";
    };
    "x86_64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-x86_64";
      sha256 = "05ngh5ark2l13fjjr75cdiw48yh9k8f4348lz84li9r6l6r21jfh";
    };
    "aarch64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-aarch64";
      sha256 = "1lph2n8h5515kq06ypgny8cx7zr12qzi2rskil9pnhp7nw7v53cw";
    };
    "x86_64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
      sha256 = "07xp7yv1mn64r9hrp3830c3c3p5hh03jf6ykjbd4706xb08s18ag";
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
