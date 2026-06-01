{ pkgs, lib, ... }:

let
  version = "0.65.0";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
      sha256 = "e68487279990696c8286e737f69e5e1e83e2714e543268a08209c99b8ee75a31";
    };
    "x86_64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_x86_64.tar.gz";
      sha256 = "28f3a223918591659dc6adecb81d1de11f6a46ae7430466244eaa5a9ab09e729";
    };
    "aarch64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_arm64.tar.gz";
      sha256 = "35cac4636f6f1a16af052d7c05e41119d1428fab30f016a53e541d302b16a859";
    };
    "x86_64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_x86_64.tar.gz";
      sha256 = "99382c2ed7f25cd8db10bab73512208fe49ccc681dc4671dfcd481631b8a1522";
    };
  };

  source = sources.${pkgs.stdenv.hostPlatform.system}
    or (throw "pup: unsupported platform ${pkgs.stdenv.hostPlatform.system}");

  pup = pkgs.stdenvNoCC.mkDerivation {
    pname = "pup";
    inherit version;

    src = pkgs.fetchurl source;

    sourceRoot = ".";
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 pup $out/bin/pup
      runHook postInstall
    '';

    meta = with lib; {
      description = "Datadog CLI companion for AI agents — 200+ commands across 33+ Datadog products";
      homepage = "https://github.com/datadog-labs/pup";
      license = licenses.asl20;
      platforms = builtins.attrNames sources;
      mainProgram = "pup";
    };
  };
in
{
  home.packages = [ pup ];
}
