{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in

lib.mkIf cfg.git.enable {
  programs.git = {
    enable = true;
    settings = {
      user.email = "mail@wantguns.dev";
      user.name = "Gunwant Jain";
      gpg.format = "ssh";

      color.ui = "auto";

      commit.template = "~/.config/git/message";
      core.editor = "nvim";

      merge.tool = "vimdiff";
      merge.conflictstyle = "diff3";
      mergetool.vimdiff.path = "nvim";

      init.defaultBranch = "main";
      pull.rebase = true;

      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  programs.delta = {
    enable = cfg.git.delta;
    enableGitIntegration = true;
  };

  home.file.".config/git/message".source = ./message;
}
