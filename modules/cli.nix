{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Search / view
    ripgrep fd bat eza jq yq-go glow

    # Git-adjacent (delta is provided by programs.git.delta in modules/git.nix)
    lazygit gh

    # Network / HTTP
    httpie curl

    # System / process
    bottom coreutils

    # Security / certs / crypto
    mkcert gnupg

    # Cloud CLIs
    awscli2

    # Native-dep libs (for building tools like imagemagick below)
    pkg-config openssl_3 readline xz zlib

    # Imaging
    imagemagick ghostscript potrace

    # Datadog
    pup

    # Postgres client (psql, pg_dump, pg_restore, libpq.dylib). Server NOT installed.
    libpq

    # DB tools
    pgcli

    # Misc
    tmux
  ];

  # Vendored pgcli config (syntax/color preferences). No DSNs stored here.
  xdg.configFile."pgcli/config".source = ../dotfiles/pgcli/config;
}
