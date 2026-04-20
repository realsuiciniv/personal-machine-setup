{ pkgs, ... }:
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
}
