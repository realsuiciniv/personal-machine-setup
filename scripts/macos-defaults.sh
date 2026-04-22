#!/usr/bin/env bash
set -euo pipefail

# macOS defaults restoration for personal-laptop.
# Re-run idempotently on a fresh Mac. Reboot or `killall Dock Finder SystemUIServer`
# after running.

echo "→ Dock"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false

echo "→ Finder"
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Finder search defaults to the CURRENT FOLDER (not "This Mac"/Spotlight-wide)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "→ Privacy: disable Spotlight/Siri web suggestions"
# Stop Spotlight/Finder search from sending queries to Apple for "suggestions"
defaults write com.apple.suggestions SuggestionsAppLibraryEnabled -bool false
defaults write com.apple.assistant.support "Assistant Enabled" -bool false
# Disable Safari's universal search (routes queries through Apple's servers).
# NOTE: Safari prefs are SIP-protected — these only succeed if the calling
# process has Full Disk Access (System Settings → Privacy & Security → FDA).
# If missing, skip silently and let the rest of the script run. Configure in
# Safari → Settings → Search manually if Safari is a primary browser.
defaults write com.apple.Safari UniversalSearchEnabled -bool false 2>/dev/null || \
  echo "  (skipped: com.apple.Safari writes need Full Disk Access)"
defaults write com.apple.Safari SuppressSearchSuggestions -bool true 2>/dev/null || true

echo "→ Screencapture"
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"

echo "→ Trackpad"
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

echo "→ Keyboard"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# F1/F2/etc. are real function keys. Hold Fn for brightness/media/volume.
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

echo "→ Login shell (nix zsh)"
NIX_ZSH="$HOME/.nix-profile/bin/zsh"
if [ -x "$NIX_ZSH" ]; then
  # Add to /etc/shells if missing (sudo required)
  if ! grep -qxF "$NIX_ZSH" /etc/shells 2>/dev/null; then
    echo "  Adding $NIX_ZSH to /etc/shells (needs sudo)..."
    echo "$NIX_ZSH" | sudo tee -a /etc/shells >/dev/null
  fi
  # chsh if not already the login shell (asks for user password)
  CURRENT_SHELL=$(dscl . -read "/Users/$(whoami)" UserShell 2>/dev/null | awk '{print $2}')
  if [ "$CURRENT_SHELL" != "$NIX_ZSH" ]; then
    echo "  Changing login shell to nix zsh (needs your user password)..."
    chsh -s "$NIX_ZSH"
    echo "  Fully quit + relaunch your terminal app for the change to take effect."
  else
    echo "  Already on nix zsh."
  fi
else
  echo "  Skipped: $NIX_ZSH not found. Run home-manager switch first."
fi

echo "→ Restart affected services"
killall Dock Finder SystemUIServer 2>/dev/null || true

echo "Done. Some changes require a reboot to fully apply."
