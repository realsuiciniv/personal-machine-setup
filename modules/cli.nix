{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-stack ];
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };

  home.packages = with pkgs; [
    # Search / view
    ripgrep fd bat eza jq yq-go glow

    # Git-adjacent (delta is provided by programs.git.delta in modules/git.nix)
    lazygit git-filter-repo

    # Network / HTTP
    httpie curl

    # System / process
    bottom coreutils coreutils-prefixed

    # Security / certs / crypto
    mkcert gnupg

    # AuthZed/SpiceDB CLI. Ships a `zed` binary that name-collides with the Zed
    # editor's Homebrew cask launcher (/opt/homebrew/bin/zed -> Zed.app).
    # modules/shell.nix re-prepends the nix profile ahead of /opt/homebrew/bin in
    # PATH so this `zed` wins (in scripts too); the editor stays reachable via the
    # `zeditor` alias defined there.
    spicedb-zed

    # Cloud CLIs
    awscli2

    # Native-dep libs (for building tools like imagemagick below)
    pkg-config openssl_3 readline xz zlib

    # Imaging
    imagemagick ghostscript potrace

    # Postgres client (psql, pg_dump, pg_restore, libpq.dylib).
    postgresql_18

    # DB tools
    pgcli

    # Misc
    tmux

    # LLM token reducer — compresses CLI output before it reaches AI coding assistants
    (pkgs.callPackage ../packages/rtk.nix {})
  ];

  # Vendored pgcli config (syntax/color preferences). No DSNs stored here.
  xdg.configFile."pgcli/config".source = ../dotfiles/pgcli/config;
}
