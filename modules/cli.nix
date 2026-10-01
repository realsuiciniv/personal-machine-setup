{ pkgs, lib, ... }:
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

    # Mermaid diagrams -> SVG/PNG/PDF (`mmdc`). Renders via Puppeteer, which
    # needs a Chromium binary; nixpkgs' chromium is Linux-only, so on macOS we
    # point it at the Chromium.app cask, bootstrapped by home.activation below.
    # Wrapped so the variable is scoped to mmdc and doesn't leak into shells.
    (symlinkJoin {
      name = "mermaid-cli-${mermaid-cli.version}";
      paths = [ mermaid-cli ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/mmdc \
          --set PUPPETEER_EXECUTABLE_PATH /Applications/Chromium.app/Contents/MacOS/Chromium
      '';
    })

    # Postgres client (psql, pg_dump, pg_restore, libpq.dylib).
    postgresql_18

    # DB tools
    pgcli

    # Misc
    tmux

    # LLM token reducer — compresses CLI output before it reaches AI coding assistants
    (pkgs.callPackage ../packages/rtk.nix {})
  ];

  # Bootstrap the Chromium cask that mermaid-cli's Puppeteer needs. Casks are
  # otherwise installed by hand (see README); this is the one exception because
  # a CLI managed here depends on it. Idempotent: skipped if Chromium.app exists.
  # Install-only: never upgrades or removes it.
  home.activation.bootstrapChromium =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d /Applications/Chromium.app ]; then
        run /opt/homebrew/bin/brew install --cask ungoogled-chromium
      fi
    '';

  # Vendored pgcli config (syntax/color preferences). No DSNs stored here.
  xdg.configFile."pgcli/config".source = ../dotfiles/pgcli/config;
}
