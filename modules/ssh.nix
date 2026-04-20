{ config, lib, ... }:
{
  programs.ssh = {
    enable = true;
    includes = [
      "${config.home.homeDirectory}/.colima/ssh_config"
    ];
    extraConfig = ''
      Host *
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };
}
