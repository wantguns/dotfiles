{
  config,
  pkgs,
  lib,
  ...
}:
{
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
    };

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
    };
  };

  home.file = {
    "dev/aion/.gitconfig".source = ./git/aion;
    "dev/aion/.gitmessage".source = ./git/aionmessage;

    # SSH host alias for the work GitHub account. The `Include ~/.ssh/config.d/*`
    # line is added to ~/.ssh/config idempotently by home.activation.sshConfigInclude.
    ".ssh/config.d/aion".text = ''
      Host github-aion
          HostName github.com
          PreferredAuthentications publickey
          IdentityFile ~/.ssh/gh-aion
    '';
  };

  # Ensure ~/.ssh/config has an `Include ~/.ssh/config.d/*` line near the top so
  # nix-managed fragments under ~/.ssh/config.d/ are picked up. The rest of
  # ~/.ssh/config remains manually managed; we only stamp this one line.
  home.activation.sshConfigInclude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="$HOME/.ssh/config"
    line='Include ~/.ssh/config.d/*'
    mkdir -p "$HOME/.ssh" "$HOME/.ssh/config.d"
    touch "$cfg"
    chmod 600 "$cfg"
    if ! grep -Fxq "$line" "$cfg"; then
      tmp=$(mktemp)
      { echo "$line"; echo; cat "$cfg"; } > "$tmp"
      mv "$tmp" "$cfg"
      chmod 600 "$cfg"
    fi
  '';

  programs.git = {
    settings = {
      url."git@github-aion:aion-intelligence".insteadOf = "https://github.com/aion-intelligence";
    };
    includes = [
      {
        condition = "gitdir:~/dev/aion/";
        path = "~/dev/aion/.gitconfig";
      }
    ];
  };
}
