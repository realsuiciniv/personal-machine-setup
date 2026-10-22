{ pkgs, lib, ... }:

let
  version = "0.9.5";

  # Prebuilt release binaries. herdr's flake builds libghostty-vt from source
  # via zig, which needs the macOS SDK and fails in the nix sandbox
  # (DarwinSdkNotFound), so we install the upstream binary directly instead.
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
      sha256 = "1qm7qdbh2afh7npli3m17174w5zlj91qjb1q45a07a0558iw4xzv";
    };
    "x86_64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-x86_64";
      sha256 = "0s8k3z8fmysm14yap4f3j5iw8mmdpw38nws5wbilarvzxh4akc2z";
    };
    "aarch64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-aarch64";
      sha256 = "0z49850w8bkcvbl6zr7l6nif9j6azyfjgvw06r95j2555mpm7mqp";
    };
    "x86_64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
      sha256 = "17cjb6gxh2wna8vv4bil82dz0qflfrpjcckwswc037jaifyfin8l";
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
