#!/usr/bin/env bash
# Update helper for this home-manager setup.
#
# Two tiers of things get updated here:
#   1. Flake inputs (nixpkgs, home-manager, sops-nix, herdr) -> `nix flake update`.
#      Everything sourced from nixpkgs moves forward with these.
#   2. Hard-pinned release binaries (version + sha256 baked into .nix files).
#      `nix flake update` does NOT touch these; this script bumps them.
#
# Usage:
#   scripts/update.sh check            # report what's outdated (read-only)
#   scripts/update.sh inputs           # nix flake update
#   scripts/update.sh pinned [tool...] # bump pinned tools (default: all outdated)
#   scripts/update.sh all              # inputs + all outdated pinned tools
#
# Pinned tools: rtk pup configcat
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m' "$*"; }
yellow() { printf '\033[33m%s\033[0m' "$*"; }
dim() { printf '\033[2m%s\033[0m' "$*"; }

# --- pinned tool registry -------------------------------------------------
# Each tool declares: the .nix file, the GitHub repo, and one URL template per
# platform (with {V} for the version), in the SAME ORDER the sha256 lines
# appear in the file. The version string is stored once as `version = "X"`.

tool_file() {
  case "$1" in
    rtk) echo "packages/rtk.nix" ;;
    herdr) echo "modules/herdr.nix" ;;
    pup) echo "modules/pup.nix" ;;
    configcat) echo "modules/configcat.nix" ;;
    *) return 1 ;;
  esac
}

tool_repo() {
  case "$1" in
    rtk) echo "rtk-ai/rtk" ;;
    herdr) echo "ogulcancelik/herdr" ;;
    pup) echo "datadog-labs/pup" ;;
    configcat) echo "configcat/cli" ;;
    *) return 1 ;;
  esac
}

# URL templates, newline-separated, in file order.
tool_urls() {
  case "$1" in
    rtk)
      echo "https://github.com/rtk-ai/rtk/releases/download/v{V}/rtk-aarch64-apple-darwin.tar.gz"
      ;;
    herdr)
      echo "https://github.com/ogulcancelik/herdr/releases/download/v{V}/herdr-macos-aarch64"
      echo "https://github.com/ogulcancelik/herdr/releases/download/v{V}/herdr-macos-x86_64"
      echo "https://github.com/ogulcancelik/herdr/releases/download/v{V}/herdr-linux-aarch64"
      echo "https://github.com/ogulcancelik/herdr/releases/download/v{V}/herdr-linux-x86_64"
      ;;
    pup)
      echo "https://github.com/datadog-labs/pup/releases/download/v{V}/pup_{V}_Darwin_arm64.tar.gz"
      echo "https://github.com/datadog-labs/pup/releases/download/v{V}/pup_{V}_Darwin_x86_64.tar.gz"
      echo "https://github.com/datadog-labs/pup/releases/download/v{V}/pup_{V}_Linux_arm64.tar.gz"
      echo "https://github.com/datadog-labs/pup/releases/download/v{V}/pup_{V}_Linux_x86_64.tar.gz"
      ;;
    configcat)
      echo "https://github.com/configcat/cli/releases/download/v{V}/configcat-cli_{V}_osx-arm64.tar.gz"
      echo "https://github.com/configcat/cli/releases/download/v{V}/configcat-cli_{V}_osx-x64.tar.gz"
      echo "https://github.com/configcat/cli/releases/download/v{V}/configcat-cli_{V}_linux-arm64.tar.gz"
      echo "https://github.com/configcat/cli/releases/download/v{V}/configcat-cli_{V}_linux-x64.tar.gz"
      ;;
    *) return 1 ;;
  esac
}

ALL_TOOLS=(rtk herdr pup configcat)

current_version() {
  local file; file="$(tool_file "$1")"
  rg -oP 'version\s*=\s*"\K[^"]+' "$file" | head -1
}

latest_version() {
  gh release view --repo "$(tool_repo "$1")" --json tagName -q .tagName 2>/dev/null \
    | sed 's/^v//'
}

# Convert a base32 sha256 (nix-prefetch-url output) to match the format the
# file already uses for that hash (base16 hex or base32).
match_hash_format() {
  local old="$1" b32="$2"
  if [[ ${#old} -eq 64 && "$old" =~ ^[0-9a-f]+$ ]]; then
    nix-hash --type sha256 --to-base16 "$b32"
  else
    echo "$b32"
  fi
}

bump_tool() {
  local tool="$1"
  local file; file="$(tool_file "$tool")" || { echo "unknown tool: $tool" >&2; return 1; }
  local cur; cur="$(current_version "$tool")"
  local new; new="$(latest_version "$tool")"

  if [[ -z "$new" ]]; then
    echo "  $(yellow "skip $tool"): could not resolve latest release" >&2
    return 0
  fi
  if [[ "$cur" == "$new" ]]; then
    echo "  $tool already at $(green "$cur")"
    return 0
  fi

  bold "  bumping $tool: $cur -> $new"

  # Old hashes in file order (parallel to tool_urls). Avoid mapfile (bash 4+;
  # macOS ships bash 3.2).
  local old_hashes=() templates=() line
  while IFS= read -r line; do old_hashes+=("$line"); done \
    < <(rg -oP 'sha256\s*=\s*"\K[^"]+' "$file")
  while IFS= read -r line; do templates+=("$line"); done \
    < <(tool_urls "$tool")

  if [[ ${#old_hashes[@]} -ne ${#templates[@]} ]]; then
    echo "  $(yellow "skip $tool"): $file has ${#old_hashes[@]} hashes but ${#templates[@]} url templates" >&2
    return 1
  fi

  local i url b32 new_hash
  for i in "${!templates[@]}"; do
    url="${templates[$i]//\{V\}/$new}"
    printf '    fetch %s\n' "$(dim "$url")"
    b32="$(nix-prefetch-url --type sha256 "$url" 2>/dev/null)"
    if [[ -z "$b32" ]]; then
      echo "  $(yellow "abort $tool"): failed to fetch $url" >&2
      return 1
    fi
    new_hash="$(match_hash_format "${old_hashes[$i]}" "$b32")"
    OLD="${old_hashes[$i]}" NEW="$new_hash" perl -i -pe 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "$file"
  done

  # Version string (and, for rtk, the literal version in its URL).
  OLD="$cur" NEW="$new" perl -i -pe 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "$file"
  echo "  $(green "updated") $file"
}

cmd_check() {
  bold "Flake inputs (run 'scripts/update.sh inputs' to bump):"
  nix flake metadata --json 2>/dev/null \
    | jq -r '.locks.nodes | to_entries[]
             | select(.value.locked.lastModified != null)
             | "  \(.key): locked \(.value.locked.lastModified | strftime("%Y-%m-%d"))"' \
    || echo "  (could not read flake metadata)"

  echo
  bold "Pinned release binaries:"
  local tool cur new
  for tool in "${ALL_TOOLS[@]}"; do
    cur="$(current_version "$tool")"
    new="$(latest_version "$tool")"
    if [[ -z "$new" ]]; then
      printf '  %-12s %s -> %s\n' "$tool" "$cur" "$(yellow '??? (lookup failed)')"
    elif [[ "$cur" == "$new" ]]; then
      printf '  %-12s %s\n' "$tool" "$(green "$cur (latest)")"
    else
      printf '  %-12s %s -> %s\n' "$tool" "$cur" "$(yellow "$new (outdated)")"
    fi
  done
}

cmd_inputs() {
  bold "Updating flake inputs..."
  nix flake update
}

cmd_pinned() {
  local tools=("$@")
  if [[ ${#tools[@]} -eq 0 ]]; then
    # default: only the outdated ones
    local tool cur new
    for tool in "${ALL_TOOLS[@]}"; do
      cur="$(current_version "$tool")"; new="$(latest_version "$tool")"
      [[ -n "$new" && "$cur" != "$new" ]] && tools+=("$tool")
    done
    if [[ ${#tools[@]} -eq 0 ]]; then
      bold "All pinned tools already up to date."
      return 0
    fi
  fi
  bold "Bumping pinned tools: ${tools[*]}"
  local t
  for t in "${tools[@]}"; do bump_tool "$t"; done
}

main() {
  local cmd="${1:-check}"; shift || true
  case "$cmd" in
    check) cmd_check ;;
    inputs) cmd_inputs ;;
    pinned) cmd_pinned "$@" ;;
    all) cmd_inputs; echo; cmd_pinned ;;
    *) echo "usage: scripts/update.sh {check|inputs|pinned [tool...]|all}" >&2; exit 1 ;;
  esac
}

main "$@"
