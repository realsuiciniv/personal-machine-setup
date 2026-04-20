# personal-machine-setup

Declarative Nix (home-manager, standalone) setup for my personal Mac.
GUI apps (casks) are installed by hand; every CLI tool is managed by Nix.

## Architecture

- home-manager + sops-nix via flakes. No nix-darwin.
- Host: `personal-laptop` (`aarch64-darwin`).
- Secrets encrypted with age; age public key in `secrets/.sops.yaml`.
- SSH identity through 1Password SSH agent — no keys on disk.
- Node via `fnm` (reads `.nvmrc`). Java via Temurin 25. Per-project flake templates under `templates/`.

## Bootstrap a fresh Mac

**One-time:** carry `~/.config/sops/age/keys.txt` from the old Mac
(USB / AirDrop / 1Password secure note). Without it, secrets cannot decrypt.

```bash
xcode-select --install                                            # Apple CLT
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install      # Determinate Nix
nix run home-manager/master -- switch \
  --flake github:realsuiciniv/personal-machine-setup#personal-laptop
```

Then:

```bash
chsh -s "$(which zsh)"                 # switch login shell
./scripts/macos-defaults.sh            # apply system defaults
# Install GUI apps by hand as you go (cursor, ghostty, 1Password, etc.).
# Sign into 1Password, enable SSH agent, add public key to GitHub.
```

## Update flow

```bash
cd ~/projects/personal/personal-machine-setup
nix flake update
home-manager switch --flake .#personal-laptop
git add flake.lock && git commit -m "nix: flake update"
```

Rollback:
```bash
git revert HEAD && home-manager switch --flake .#personal-laptop
```

## Adding a tool

- CLI tool → edit `modules/cli.nix`.
- Language toolchain → edit `modules/languages.nix`.
- GUI app → install by hand via brew/app store/direct download.

## Per-project dev shells

For a repo that needs pinned tooling:

```bash
cd my-project
nix flake new -t github:realsuiciniv/personal-machine-setup#node .
echo "use flake" > .envrc && direnv allow
```
