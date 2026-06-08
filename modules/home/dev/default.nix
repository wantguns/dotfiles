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
        gopls
        golangci-lint-langserver
      ];
    })
    (lib.mkIf cfg.dev.python { home.packages = [ pkgs.ty ]; })
    (lib.mkIf cfg.dev.terraform { home.packages = [ pkgs.terraform-ls ]; })
    (lib.mkIf cfg.dev.nodejs {
      home.packages = with pkgs; [
        typescript-language-server
        typescript
      ];
    })
    (lib.mkIf cfg.dev.lua { home.packages = [ pkgs.lua-language-server ]; })
    (lib.mkIf cfg.dev.zig { home.packages = [ pkgs.zls ]; })
  ];
}
