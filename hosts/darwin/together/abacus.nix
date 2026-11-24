{ config, pkgs, ... }:
let
  user = config.homebrew.user;
in
{
  system.activationScripts.preActivation.text = ''
    sudo --user=${user} --set-home /bin/sh -c 'umask 077; mkdir -p ~/.homebrew; t=$(${pkgs.gh}/bin/gh auth token) && printf "HOMEBREW_GITHUB_API_TOKEN=%s\n" "$t" > ~/.homebrew/brew.env' || echo "warning: no gh token for Homebrew" >&2
  '';
  system.activationScripts.postActivation.text = ''
    rm -f ~${user}/.homebrew/brew.env
  '';

  homebrew = {
    taps = [
      {
        name = "togethersecured/abacus";
        clone_target = "https://github.com/togethersecured/abacus";
        trusted = true;
      }
    ];
    brews = [ "togethersecured/abacus/abacus" ];
  };

  home-manager.users.${user} =
    { config, ... }:
    {
      home.file.".local/bin/abacus".source =
        config.lib.file.mkOutOfStoreSymlink "/opt/homebrew/bin/abacus";
      home.file.".local/bin/irmea" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          exec abacus --profile irmea "$@"
        '';
      };
      home.file.".abacus/profiles/irmea.md".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dev/together/irmea/deploy/tui/irmea.md";
    };
}
