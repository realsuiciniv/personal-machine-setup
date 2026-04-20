{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Search / view
    ripgrep fd bat eza jq yq-go glow

    # Git-adjacent
    git-delta lazygit gh

    # Network / HTTP
    httpie curl

    # System / process
    bottom coreutils

    # Security / certs
    mkcert

    # Native-dep libs (for building tools like imagemagick below)
    pkg-config openssl_3 readline xz zlib

    # Imaging
    imagemagick ghostscript potrace

    # Datadog
    pup

    # DB tools
    pgcli

    # Misc
    tmux
  ];
}
