{ config, pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    # Closure-size optimization: Lua is neovim's native language; modern plugins
    # rarely need the Ruby or Python3 language providers. Skip them by default
    # (matches the upcoming stateVersion 26.05 behavior).
    withRuby = false;
    withPython3 = false;
  };

  # Place nvim config tree (init.lua + lazy-lock + any lua/ subdir)
  xdg.configFile."nvim" = {
    source = ../dotfiles/nvim;
    recursive = true;
  };

  # Ghostty is distributed as a cask; we only manage its config here.
  xdg.configFile."ghostty/config".source = ../dotfiles/ghostty/config;

  # Rio terminal (also installed via cask)
  xdg.configFile."rio/config.toml".source = ../dotfiles/rio/config.toml;

  # Hack Nerd Font — install and expose to macOS Font Book via ~/Library/Fonts symlinks.
  home.packages = [ pkgs.nerd-fonts.hack ];

  home.file."Library/Fonts/HackNerdFont-Regular.ttf".source =
    "${pkgs.nerd-fonts.hack}/share/fonts/truetype/NerdFonts/Hack/HackNerdFont-Regular.ttf";
  home.file."Library/Fonts/HackNerdFont-Bold.ttf".source =
    "${pkgs.nerd-fonts.hack}/share/fonts/truetype/NerdFonts/Hack/HackNerdFont-Bold.ttf";
  home.file."Library/Fonts/HackNerdFont-Italic.ttf".source =
    "${pkgs.nerd-fonts.hack}/share/fonts/truetype/NerdFonts/Hack/HackNerdFont-Italic.ttf";
  home.file."Library/Fonts/HackNerdFont-BoldItalic.ttf".source =
    "${pkgs.nerd-fonts.hack}/share/fonts/truetype/NerdFonts/Hack/HackNerdFont-BoldItalic.ttf";
  home.file."Library/Fonts/HackNerdFontMono-Regular.ttf".source =
    "${pkgs.nerd-fonts.hack}/share/fonts/truetype/NerdFonts/HackMono/HackNerdFontMono-Regular.ttf";
}
