# personal-machine-setup

Declarative Nix configuration for my personal laptop. Every CLI tool, shell
config, editor config, and dotfile is managed by home-manager. GUI apps
(casks) are installed by hand.

## Architecture

- **home-manager** as a flake, standalone. No nix-darwin and no NixOS module,
  so the same config works on macOS and (future) Linux.
- **sops-nix** for encrypted secrets (age). Recipients are listed in
  `secrets/.sops.yaml`; decrypted values are exported as env vars at zsh startup.
- **1Password SSH agent** provides SSH identity and git commit signing. No
  private keys on disk.
- **Node** via `fnm` with `--use-on-cd`. A home-level `~/.nvmrc` acts as the
  default, so leaving a project with its own `.nvmrc` reverts to the pinned
  version instead of sticking on the project's.
- **Per-project dev shells** under `templates/` (Node, Java, Python), wired
  via `direnv` + `nix-direnv`.

## Layout

```
flake.nix                       inputs + homeConfigurations."personal-laptop"
hosts/personal-laptop/          per-host entrypoint, imports every module
modules/
  cli.nix                       ripgrep, fd, eza, bat, jq, fzf, zoxide, ...
  shell.nix                     zsh + powerlevel10k + fnm hook + aliases
  git.nix                       git config, delta, SSH signing
  editors.nix                   neovim
  languages.nix                 node/java/python/go/bun/pnpm/dotnet/llvm
  containers.nix                docker client + colima
  ssh.nix                       ssh_config (1Password IdentityAgent)
  claude-code.nix               claude-code CLI + dotfiles
  secrets.nix                   sops-nix wiring + env-var exports
dotfiles/                       raw configs linked in by home-manager
  zsh/.p10k.zsh
  nvim/init.lua
  ghostty/config, rio/config.toml
  claude/..., git/ignore, pgcli/config
scripts/
  macos-defaults.sh             one-shot: Dock, Finder, keyboard, Safari, ...
secrets/
  .sops.yaml                    age recipients
  secrets.yaml                  encrypted env vars
templates/
  node/, java/, python/         per-project dev-shell templates
```

## Bootstrap a fresh machine

**Prerequisite.** Carry `~/.config/sops/age/keys.txt` from the old machine
(USB, AirDrop, or a 1Password secure note). Without it, sops-nix cannot
decrypt `secrets/secrets.yaml` and activation will fail.

```bash
# macOS only: Apple command-line tools
xcode-select --install

# Determinate Nix installer (works on macOS and Linux)
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install

# Apply the home-manager config
nix run home-manager/master -- switch \
  --flake github:realsuiciniv/personal-machine-setup#personal-laptop
```

After the first switch:

```bash
chsh -s "$(which zsh)"              # login shell to the nix-managed zsh
./scripts/macos-defaults.sh         # apply macOS defaults (macOS only)
```

Then, by hand:

- Install GUI apps (1Password, Ghostty, Cursor, etc.).
- Sign into 1Password, enable its SSH agent, add the public key to GitHub.

## Day to day

Two aliases defined in `modules/shell.nix`:

```
hms     home-manager switch --flake .#personal-laptop
hmu     nix flake update && hms           (bumps inputs, then rebuilds)
```

Rollback the last change:

```bash
git revert HEAD && hms
```

## Adding a tool

- CLI tool: `modules/cli.nix`
- Language runtime or toolchain: `modules/languages.nix`
- Editor config: `modules/editors.nix` or `dotfiles/nvim/`
- GUI app: not managed by nix. Install by hand (brew cask, App Store, direct download).

## Per-project dev shells

For a repo that needs pinned tooling:

```bash
cd my-project
nix flake new -t github:realsuiciniv/personal-machine-setup#node .
echo "use flake" > .envrc && direnv allow
```

Each template honors project pin files:

- Node: `.nvmrc` (major version).
- Python: `.python-version` (major.minor); uv manages deps.
- Java: Temurin 25 with maven + gradle.

## Secrets

- Encrypted env vars live in `secrets/secrets.yaml`.
- `secrets/.sops.yaml` lists the age public keys allowed to decrypt.
- Edit with `sops secrets/secrets.yaml` (decrypts, opens `$EDITOR`, re-encrypts on save).
- `modules/secrets.nix` declares which keys to expose and exports them as env
  vars when zsh starts. To add a new secret: add it under `sops.secrets` in
  that module, then add an `_load_secret` line for the env var.
