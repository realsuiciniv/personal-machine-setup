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

echo "→ Restart affected services"
killall Dock Finder SystemUIServer 2>/dev/null || true

echo "Done. Some changes require a reboot to fully apply."
