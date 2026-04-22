{ config, pkgs, lib, ... }:
{
  # Ensure ~/.local/bin is on PATH for the self-installed claude binary.
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  # Install Claude Code via Anthropic's native installer, only if not already present.
  # Activation hooks run with a minimal PATH; the install.sh script needs:
  #   - curl (nix-provided, for fetches)
  #   - shasum (macOS system tool at /usr/bin/shasum, for checksum verification)
  #   - standard unix tools (tar, mktemp, etc — all at /usr/bin or /bin)
  home.activation.installClaudeCode =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! command -v claude >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/claude" ]; then
        export PATH="${pkgs.curl}/bin:/usr/bin:/bin:$PATH"
        curl -fsSL https://claude.ai/install.sh | bash
      fi
    '';

  # Declarative Claude Code config (plumbing only).
  home.file = {
    ".claude/CLAUDE.md".source     = ../dotfiles/claude/CLAUDE.md;
    ".claude/settings.json".source = ../dotfiles/claude/settings.json;
    ".claude/.mcp.json".source     = ../dotfiles/claude/.mcp.json;
    ".claude/statusline.sh" = {
      source = ../dotfiles/claude/statusline.sh;
      executable = true;
    };
    ".claude/hooks/prefer-rg-fd.sh" = {
      source = ../dotfiles/claude/hooks/prefer-rg-fd.sh;
      executable = true;
    };
  };
}
