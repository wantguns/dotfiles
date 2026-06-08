{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in

lib.mkIf cfg.kubernetes {
  programs.k9s = {
    enable = true;
    settings = {
      k9s = {
        ui = {
          headless = true;
          logoless = true;
        };
        skin = "transparent";
      };
    };
    skins = {
      transparent = ./k9s-transparent-skin.yaml;
    };
  };

  home.packages = with pkgs; [
    kubectl
    kubernetes-helm
  ];
}
