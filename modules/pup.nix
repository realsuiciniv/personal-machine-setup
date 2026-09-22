{ pkgs, lib, ... }:

let
  version = "1.22.1";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
      sha256 = "ad6f155c51443fa8303396679f464e666fbcdee56c5424f442f1c9bc9d048364";
    };
    "x86_64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_x86_64.tar.gz";
      sha256 = "ab57b3af24469585a0041f57d79487bace90261ca2c7a10defbb2faa0c5cf83f";
    };
    "aarch64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_arm64.tar.gz";
      sha256 = "8548cbd4bbb188bc6c6cd0e293fb757aca56ce6dca0b50e517cd4138b50dd07d";
    };
    "x86_64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_x86_64.tar.gz";
      sha256 = "7960cc0c63c3b9f227efd17eace4bdcf3cc3e0a4d43f563aae54a4248b174999";
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
