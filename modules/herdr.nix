{ pkgs, lib, ... }:

let
  version = "0.7.0";

  # Prebuilt release binaries. herdr's flake builds libghostty-vt from source
  # via zig, which needs the macOS SDK and fails in the nix sandbox
  # (DarwinSdkNotFound), so we install the upstream binary directly instead.
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
      sha256 = "04g37y1np4y3b30c7an92mgayizg1i5ci0bcj0218v9rvv2w2ih9";
    };
    "x86_64-darwin" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-x86_64";
      sha256 = "03vwsbc1vpzgwsgsq8gdpy06miimhs6rv6qhdrid1f3rgjvcsqbc";
    };
    "aarch64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-aarch64";
      sha256 = "0wixavl14x2xfhvpq37d05bmpvvgr2id5imw1f3mrhhlqmcpjh3p";
    };
    "x86_64-linux" = {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
      sha256 = "0frn82pkp5j6j8lsj3jzdggphic50zn1j2nkknd6012f1945samd";
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
