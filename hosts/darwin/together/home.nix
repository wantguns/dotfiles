{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./aerc.nix ];

  features = {

    theme = "moonfly";

    editors = {
      nvim = {
        enable = true;
        ui = true;
        lsp = true;
        copilot = false;
        obsidian = false;
      };
      emacs.enable = true;
    };

    ai = {
      opencode = false;
      pi = true;
      extraSkills = [
        "${config.home.homeDirectory}/dev/together/tcloud-knowledge-base/pi-skills"
      ];
    };

    shell.zsh = {
      enable = true;
      powerlevel10k = true;
    };

    git = {
      enable = true;
    };

    tmux = true;
    fzf = true;
    aerc = true;
    alacritty = true;
    ghostty = true;
    newsboat = true;
    kubernetes = true;
    mpv = true;
    firefox = true;

    dev = {
      go = true;
      python = true;
      terraform = true;
      nodejs = true;
      lua = true;
      zig = true;
      bash = true;
    };
  };

  home.sessionVariables = {
    DOCKER_HOST = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";
    TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock";
  };

  home.file = {
    "dev/together/.gitconfig".source = ./git/together;
    "dev/together/.gitmessage".source = ./git/togethermessage;
    ".finicky.js".text = builtins.replaceStrings
      [ "@FIREFOX_APP@" ]
      [ "${config.programs.firefox.finalPackage}/Applications/Firefox.app" ]
      (builtins.readFile ./finicky.js);
  };

  programs.git = {
    includes = [
      {
        condition = "gitdir:~/dev/together/";
        path = "~/dev/together/.gitconfig";
      }
    ];
  };
}
