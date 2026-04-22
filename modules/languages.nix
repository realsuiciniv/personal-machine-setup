{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # Node: tool is nix-declared, versions are managed by fnm via .nvmrc
    fnm

    # Java: current LTS pinned globally. Per-project overrides via templates/java flake.
    temurin-bin-25

    # Python + userland tools
    python314
    pipx
    uv

    # Go
    go
    gopls
    go-tools    # provides staticcheck

    # JavaScript runtimes/toolchain
    bun
    pnpm

    # .NET
    dotnet-sdk

    # LLVM toolchain (flags exported below)
    llvm
  ];

  # LLVM compiler flags — rewrite the old brew-prefixed paths to nix store paths.
  home.sessionVariables = {
    LDFLAGS  = "-L${pkgs.llvm}/lib";
    CPPFLAGS = "-I${pkgs.llvm.dev}/include";
  };

  # Home-level .nvmrc: fnm's --use-on-cd walks up from $PWD, so any dir under
  # $HOME without its own .nvmrc falls back to this, and leaving a project
  # snaps node back to v24 instead of sticking on the project's version.
  home.file.".nvmrc".text = "24";

  # Bootstrap Node 24 LTS on first home-manager switch.
  # Idempotent: skipped if v24 is already installed.
  # Per-project .nvmrc still wins via fnm's --use-on-cd hook in modules/shell.nix.
  home.activation.bootstrapNodeLTS =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! ${pkgs.fnm}/bin/fnm list 2>/dev/null | grep -q 'v24'; then
        ${pkgs.fnm}/bin/fnm install 24
        ${pkgs.fnm}/bin/fnm default 24
      fi
    '';
}
