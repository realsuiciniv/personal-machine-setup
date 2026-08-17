{ pkgs, lib, ... }:

let
  version = "1.10.9";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
      sha256 = "15e6c111716445f03d4adedf164b6ab72bf8d50e6d2d35a75332f310e652dd66";
    };
    "x86_64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_x86_64.tar.gz";
      sha256 = "c21911b93799a8234fef21683584155fb66146cf67ff245468814d22bcc0d1f3";
    };
    "aarch64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_arm64.tar.gz";
      sha256 = "a37cdf4488cfed1b4408594b198581d693d1b7a523d2169dc326bf0bb08f66ac";
    };
    "x86_64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_x86_64.tar.gz";
      sha256 = "7716c63f92f0be9d6ecd47766e9297a57454353aa93b823be57d704180525bf4";
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
