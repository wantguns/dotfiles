{ config, pkgs, ... }: {
  features = {

    # theme = "gruvbox-light";
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

    ai = true;

    shell.zsh = {
      enable = true;
      powerlevel10k = true;
    };

    git = {
      enable = true;
      delta = true;
    };

    tmux = true;
    fzf = true;
    aerc = false;
    secrets = true;
    alacritty = true;
    ghostty = true;
    newsboat = false;
    kubernetes = true;

    dev = {
      go = true;
      python = true;
      terraform = true;
      nodejs = true;
      lua = true;
      zig = true;
    };
  };

  home.file = {
    "dev/aion/.gitconfig".source = ./git/aion;
    "dev/aion/.gitmessage".source = ./git/aionmessage;

    "Library/Application Support/Raycast/scripts/emacs-client.sh" = {
        executable = true;
        text = ''
        #!/bin/bash
        # @raycast.schemaVersion 1
        # @raycast.title Emacs Client
        # @raycast.mode silent

        exec ${config.services.emacs.package}/bin/emacsclient -c -n
        '';
    };
  };

  programs.git = {
      settings = {
        url."git@github-aion:aion-intelligence".insteadOf = "https://github.com/aion-intelligence";
      };
      includes = [{
        condition = "gitdir:~/dev/aion/";
        path = "~/dev/aion/.gitconfig";
      }];
  };
}

