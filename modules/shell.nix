{ config, pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = false;      # fast-syntax-highlighting replaces it
    historySubstringSearch.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "macos" "fzf" ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ../dotfiles/zsh;
        file = ".p10k.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
    ];

    shellAliases = {
      # Claude helpers
      claude-unsafe = "claude --dangerously-skip-permissions";
      claude-update = "claude update";

      # The bare `zed` command is the AuthZed/SpiceDB CLI (modules/cli.nix).
      # Launch the Zed.app editor from the terminal with `zeditor` instead.
      zeditor = "/Applications/Zed.app/Contents/MacOS/cli";

      # Modern replacements
      ls  = "eza";
      ll  = "eza -l --git";
      la  = "eza -la --git";
      cat = "bat --plain --paging=never";

      # Git
      g   = "git";
      gs  = "git status";
      gd  = "git diff";
      # Pin explicitly: oh-my-zsh's git plugin also defines this, but the
      # `gpr` binary from coreutils-prefixed (GNU `pr`) shares the name. Owning
      # the alias here keeps `gpr` = pull --rebase regardless of plugin changes.
      gpr = "git pull --rebase";

      # Containers (colima lifecycle — not autostarted)
      coup   = "colima start && docker ps";
      codown = "colima stop";

      # Home-manager lifecycle (absolute path — works from any cwd)
      hms = "home-manager switch --flake ~/projects/personal/personal-machine-setup#personal-laptop";
      hmu = "(cd ~/projects/personal/personal-machine-setup && nix flake update && home-manager switch --flake .#personal-laptop)";
    };

    # Login-shell bootstrap. macOS system updates periodically reset
    # /etc/zshrc and remove the nix-daemon source line, which drops
    # ~/.nix-profile/bin out of PATH and breaks fnm, zoxide, eza, etc.
    # Sourcing it from a home-manager-managed ~/.zprofile makes the
    # bootstrap survive those resets.
    profileExtra = ''
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      # macOS path_helper (/etc/zprofile) rebuilds PATH with /etc/paths.d entries
      # first, which hoists /opt/homebrew/bin ahead of the nix profile. brew is
      # casks-only here, so its only bins are GUI launchers — and when one shares
      # a name with a nix CLI (Zed.app's `zed` vs AuthZed's `zed`) the cask shim
      # would shadow the tool, in scripts too. Re-prepend the nix profiles after
      # path_helper has run and dedupe, so nix-managed CLIs always win.
      path=("$HOME/.nix-profile/bin" "/nix/var/nix/profiles/default/bin" $path)
      typeset -U path PATH
    '';

    initContent = ''
      setopt NO_NOMATCH
      eval "$(fnm env --use-on-cd --shell zsh)"

      # brew guardrail: brew is reserved for casks on this machine.
      brew() {
        case "$1" in
          install|reinstall)
            if [[ " $* " != *" --cask "* ]] && [[ "$2" != "--cask" ]]; then
              print -P "%F{red}✗ brew is reserved for casks on this machine.%f"
              print "  Formulae are managed by nix (~/projects/personal/personal-machine-setup/modules/cli.nix)."
              print "  - Cask install:   brew install --cask <name>"
              print "  - Escape hatch:   command brew $*"
              return 1
            fi
            ;;
        esac
        command brew "$@"
      }

      # Escape hatch for quick/experimental aliases and machine-local config
      # without rebuilding home-manager. Promote keepers into this module.
      [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    USE_BUILTIN_RIPGREP = "0";
    BUN_INSTALL = "${config.home.homeDirectory}/.bun";
    DOTNET_ROOT = "${pkgs.dotnet-sdk}/libexec";
    # sops looks at macOS default (~/Library/Application Support/sops/age/keys.txt)
    # but we store the key under XDG. Point sops at it for every shell.
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    # Point ssh / ssh-keygen at the 1Password SSH agent socket. The IdentityAgent
    # line in ssh_config covers `ssh`, but ssh-keygen (used by git signing)
    # doesn't read ssh_config — it only honors SSH_AUTH_SOCK.
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.bun/bin"
    "${config.home.homeDirectory}/.dotnet/tools"
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/projects/clutch/clutch-cli"
  ];
}
