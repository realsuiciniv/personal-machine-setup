{ pkgs, lib, ... }:

let
  version = "2.2.1";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
      sha256 = "cdab2cbb1639a196398caa99332dbff1eb3feb3f2d6edc59884d67d735724389";
    };
    "x86_64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_x86_64.tar.gz";
      sha256 = "817b6446664f76be35b3b09ec07d80a3cee4696aaaf493b3d91c631463050459";
    };
    "aarch64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_arm64.tar.gz";
      sha256 = "1c3bb1401878c764e168bd3d131b39d7af92a6551a85a451274d28b91ad471ff";
    };
    "x86_64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_x86_64.tar.gz";
      sha256 = "254189a4a4d7e9d2f2df6d1e28ef01f28ff629b0f30c5ac5cc10d3954fae4132";
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
