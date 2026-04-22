{ config, pkgs, lib, ... }:
{
  # Ensure ~/.local/bin is on PATH for the self-installed claude binary.
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  # Install Claude Code via Anthropic's native installer, only if not already present.
  # Activation hooks run with a minimal PATH; the install.sh script needs:
  #   - curl (nix-provided, for fetches)
  #   - shasum (macOS system tool at /usr/bin/shasum, for checksum verification)
  #   - standard unix tools (tar, mktemp, etc — all at /usr/bin or /bin)
  # PATH change is wrapped in a subshell so it doesn't leak to subsequent
  # activation steps (which depend on GNU coreutils — e.g., linkGeneration
  # uses `readlink -e` which BSD readlink at /usr/bin does not support).
  home.activation.installClaudeCode =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! command -v claude >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/claude" ]; then
        (
          export PATH="${pkgs.curl}/bin:/usr/bin:/bin:$PATH"
          curl -fsSL https://claude.ai/install.sh | bash
        )
      fi
    '';

  # Claude Code writes to ~/.claude/settings.json (and other files) at
  # runtime, so we intentionally do not symlink them from the nix store.
  # Config lives under ~/.claude/ as regular writable files, owned by
  # Claude Code, not home-manager.
}
