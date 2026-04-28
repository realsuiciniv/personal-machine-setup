{ pkgs, lib, ... }:

let
  version = "2.6.1";

  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/configcat/cli/releases/download/v${version}/configcat-cli_${version}_osx-arm64.tar.gz";
      sha256 = "1992aa9f73dcecd910d75d4018041686f2a89c3538e6aff69c34a316ac7ccde5";
    };
    "x86_64-darwin" = {
      url = "https://github.com/configcat/cli/releases/download/v${version}/configcat-cli_${version}_osx-x64.tar.gz";
      sha256 = "4c2b037b4812cde67960c32b14c0b9ee749398cc08a26a83d5acc2753dc14d57";
    };
    "aarch64-linux" = {
      url = "https://github.com/configcat/cli/releases/download/v${version}/configcat-cli_${version}_linux-arm64.tar.gz";
      sha256 = "b6186ee1a8ec804cc53dd447f8b566421c39e0f8388518e9dc640d775b8e689c";
    };
    "x86_64-linux" = {
      url = "https://github.com/configcat/cli/releases/download/v${version}/configcat-cli_${version}_linux-x64.tar.gz";
      sha256 = "91cd6d8ade9d7a63e6601acb4c2a36ebc337a022532770cde4829f590ac5c82f";
    };
  };

  source = sources.${pkgs.stdenv.hostPlatform.system}
    or (throw "configcat-cli: unsupported platform ${pkgs.stdenv.hostPlatform.system}");

  configcat-cli = pkgs.stdenvNoCC.mkDerivation {
    pname = "configcat-cli";
    inherit version;

    src = pkgs.fetchurl source;

    sourceRoot = ".";
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 configcat $out/bin/configcat
      runHook postInstall
    '';

    meta = with lib; {
      description = "ConfigCat command line interface for managing feature flags and config values";
      homepage = "https://github.com/configcat/cli";
      license = licenses.mit;
      platforms = builtins.attrNames sources;
      mainProgram = "configcat";
    };
  };
in
{
  home.packages = [ configcat-cli ];
}
