{ config, pkgs, lib, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      github_token      = { };
      dd_api_key        = { };
      dd_app_key        = { };
      anthropic_api_key = { };
      configcat_user    = { };
      configcat_pass    = { };
      claude_credentials = {
        path = "${config.home.homeDirectory}/.claude/.credentials.json";
        mode = "0600";
      };
    };
  };

  # Export secret env vars at zsh startup. Reference each secret's resolved
  # path directly so this stays correct regardless of where sops-nix writes.
  # Each read is guarded; absent files no-op.
  programs.zsh.initExtra = ''
    _load_secret() {
      local var="$1" file="$2"
      [[ -r "$file" ]] && export "$var=$(<"$file")"
    }
    _load_secret GITHUB_PERSONAL_ACCESS_TOKEN "${config.sops.secrets.github_token.path}"
    _load_secret DD_API_KEY                   "${config.sops.secrets.dd_api_key.path}"
    _load_secret DD_APP_KEY                   "${config.sops.secrets.dd_app_key.path}"
    _load_secret ANTHROPIC_API_KEY            "${config.sops.secrets.anthropic_api_key.path}"
    _load_secret CONFIGCAT_API_USER           "${config.sops.secrets.configcat_user.path}"
    _load_secret CONFIGCAT_API_PASS           "${config.sops.secrets.configcat_pass.path}"
    unset -f _load_secret
  '';
}
