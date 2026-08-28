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
    (lib.mkIf cfg.shell.zsh.enable {
      programs.zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;

        completionInit = "autoload -U compinit && compinit -C";

        history = {
          append = true;
          extended = true;
          size = 10000;
          save = 1000000;
        };

        initContent = builtins.readFile ./zshrc;

        plugins = lib.optional cfg.shell.zsh.powerlevel10k {
          name = "zsh-powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        };
      };

      home.activation.zshCompdump = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        rm -f "$HOME/.zcompdump"
        ${config.programs.zsh.package}/bin/zsh -i -c exit </dev/null >/dev/null 2>&1 || true
      '';
    })

    (lib.mkIf (cfg.shell.zsh.enable && cfg.shell.zsh.powerlevel10k) {
      home.file.".p10k.zsh".source = ./p10k.zsh;
    })
  ];
}
