{ config, pkgs, ... }:
let dot = "${config.home.homeDirectory}/dotfiles"; in
{
  home.packages = with pkgs; [
    neovim
    lazygit
    claude-code

    # Compilers / toolchains
    clang
    llvm

    # LSPs
    lua-language-server
    pyright
    ruff
    rust-analyzer
    tree-sitter
    glslang
    shader-slang # provides slangd LSP
  ];

  xdg.configFile.nvim.source =
    config.lib.file.mkOutOfStoreSymlink "${dot}/modules/nvim";
}
