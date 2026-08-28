{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in

lib.mkIf cfg.tmux {
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-processes '"~nvim" "~newsboat" "~aerc" "~k9s" pi'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15' # minutes
        '';
      }
    ];
    extraConfig = builtins.replaceStrings [ "@CONTINUUM_SAVE@" ] [
      "#(${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh)"
    ] (builtins.readFile ./tmux.conf);
  };
}
