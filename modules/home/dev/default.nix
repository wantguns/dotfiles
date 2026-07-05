{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.dev.go {
      home.packages = with pkgs; [
        go
        gopls
        golangci-lint
        golangci-lint-langserver
      ];
    })

    (lib.mkIf cfg.dev.rust {
      home.packages = with pkgs; [
        rustc
        cargo
        rust-analyzer
      ];
    })

    (lib.mkIf cfg.dev.python {
      home.packages = with pkgs; [
        uv
        ty
        ruff
        python3
      ];
    })

    (lib.mkIf cfg.dev.terraform {
      home.packages = with pkgs; [
        terraform
        terraform-ls
      ];
    })

    (lib.mkIf cfg.dev.nodejs {
      home.packages = with pkgs; [
        nodejs
        pnpm
        yarn
        typescript
        typescript-language-server
      ];
    })

    (lib.mkIf cfg.dev.lua {
      home.packages = with pkgs; [
        lua
        luarocks
        lua-language-server
      ];
    })

    (lib.mkIf cfg.dev.zig {
      home.packages = with pkgs; [
        zig
        zls
      ];
    })
  ];
}
