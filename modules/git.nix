{ config, pkgs, lib, ... }:
{
  programs.git = {
    enable = true;

    userName  = "Vinicius Costa";
    userEmail = "vinicius.costa@withclutch.com";

    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
    };

    extraConfig = {
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
      mergetool."nvimdiff".cmd = ''nvim -d "$LOCAL" "$REMOTE" "$MERGED" -c "wincmd J"'';
      difftool.prompt = false;
      mergetool.prompt = false;

      help.autocorrect = "prompt";
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";

      commit = {
        verbose = true;
        gpgsign = true;
      };
      gpg.format = "ssh";
      # Populated once the new Mac's 1Password SSH key is generated.
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";

      # URL aliases
      url."https://github.com/dracula/".insteadOf = "dracula://";

      # Global ignore
      core.excludesFile = "${config.home.homeDirectory}/.config/git/ignore";

      # Dracula color scheme
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

    aliases = {
      coauthor = ''
        !f() { msg="$1"; shift; for author in "$@"; do msg="$msg\n\nCo-authored-by: $author"; done; printf "%b" "$msg" | git commit -F -; }; f
      '';
    };
  };

  xdg.configFile."git/ignore".source = ../dotfiles/git/ignore;
}
