{ pkgs, lib, ... }:

let
  version = "1.18.1";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
      sha256 = "bffa10dd45eae9768ad5a687ee67a3a131314b72d6c7cf730415ae8f744d207b";
    };
    "x86_64-darwin" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Darwin_x86_64.tar.gz";
      sha256 = "dc6b7c82a7ace6b02566881c43e3c5cc1bdae76231681ee41992f0178a8134e4";
    };
    "aarch64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_arm64.tar.gz";
      sha256 = "85619302e9b74a091ee4ab76f47b7a435588db61369dca9058376de229d5f11c";
    };
    "x86_64-linux" = {
      url = "https://github.com/datadog-labs/pup/releases/download/v${version}/pup_${version}_Linux_x86_64.tar.gz";
      sha256 = "e966dd6fe01cd3b75cc4f8eddf5bb38a463097eecf73cfbe0c4437db84604853";
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
