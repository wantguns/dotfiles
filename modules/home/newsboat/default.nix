{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in

lib.mkIf cfg.newsboat {
  programs.newsboat = {
    enable = true;
    extraConfig =
      builtins.readFile ./config
      + ''
        miniflux-tokeneval "cat ${config.sops.secrets."miniflux/apitoken".path}"
      ''
      + lib.optionalString cfg.mpv (
        let
          mpv = lib.getExe config.programs.mpv.finalPackage;
        in
        ''
          macro v set browser "${mpv} --ontop %u"; open-in-browser ; set browser "w3m %u"
        ''
      )
      + lib.optionalString cfg.firefox (
        let
          firefox =
            if pkgs.stdenv.isDarwin then
              "open ${config.programs.firefox.finalPackage}/Applications/Firefox.app --args"
            else
              lib.getExe config.programs.firefox.finalPackage;
        in
        ''
          macro l set browser "${firefox} %u"; open-in-browser ; set browser "w3m %u"
        ''
      );
  };

  home.packages = [ pkgs.w3m ];

  sops.secrets."miniflux/apitoken" = { };
}
