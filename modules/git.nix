{ config, pkgs, lib, ... }:
{
  programs.git = {
    enable = true;

    # Signing config — unified sub-module (replaces scattered
    # settings.user.signingkey / settings.commit.gpgsign / settings.gpg.format)
    signing = {
      format = "ssh";
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    settings = {
      user = {
        name  = "Vinicius Costa";
        email = "vinicius.costa@withclutch.com";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
      merge = {
        conflictstyle = "zdiff3";
        tool = "nvimdiff";
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
        tool = "nvimdiff";
      };
      mergetool = {
        "nvimdiff".cmd = ''nvim -d "$LOCAL" "$REMOTE" "$MERGED" -c "wincmd J"'';
        prompt = false;
      };
      difftool.prompt = false;

      help.autocorrect = "prompt";
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";

      commit.verbose = true;

      url."https://github.com/dracula/".insteadOf = "dracula://";

      core.excludesFile = "${config.home.homeDirectory}/.config/git/ignore";

      color.ui = "auto";
      "color \"branch\"" = {
        current = "cyan bold reverse";
        local = "white";
        remote = "cyan";
      };
      "color \"diff\"" = {
        func = "cyan";
        whitespace = "magenta reverse";
        meta = "white";
        frag = "cyan bold reverse";
        old = "red";
        new = "green";
      };
      "color \"grep\"" = {
        linenumber = "white";
      };
      "color \"status\"" = {
        added = "green";
        changed = "yellow";
        remoteBranch = "cyan bold reverse";
        unmerged = "magenta bold reverse";
        untracked = "red";
        updated = "green bold";
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Dracula";
    };
  };

  xdg.configFile."git/ignore".source = ../dotfiles/git/ignore;
}
