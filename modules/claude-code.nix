{ config, pkgs, lib, ... }:
{
  # Ensure ~/.local/bin is on PATH for the self-installed claude binary.
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  # Install Claude Code via Anthropic's native installer, only if not already present.
  # The installer script (fetched via curl and piped to bash) internally runs
  # `command -v curl` to pick a downloader for its nested fetches — so curl needs
  # to be on PATH for the child bash, not just reachable by nix store path.
  home.activation.installClaudeCode =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! command -v claude >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/claude" ]; then
        export PATH="${pkgs.curl}/bin:$PATH"
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
