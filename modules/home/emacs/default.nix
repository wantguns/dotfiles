{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in

lib.mkIf cfg.editors.emacs.enable {
  programs.emacs = {
    enable = true;

    extraPackages = (
      epkgs: [
        epkgs.vterm
        epkgs.treesit-grammars.with-all-grammars
      ]
    );
    extraConfig = builtins.readFile ./emacs.el;
  };

  services.emacs.enable = true;
}
