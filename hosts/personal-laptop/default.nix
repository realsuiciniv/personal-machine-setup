{ config, pkgs, lib, ... }:
{
  imports = [
    ../../modules/cli.nix
    ../../modules/shell.nix
    ../../modules/git.nix
    ../../modules/editors.nix
    ../../modules/languages.nix
    ../../modules/containers.nix
    ../../modules/ssh.nix
    ../../modules/claude-code.nix
    ../../modules/pup.nix
    ../../modules/secrets.nix
  ];

  home.username = "vinicius.costa";
  home.homeDirectory = "/Users/vinicius.costa";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
}
