{
  description = "Nix System Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko/latest";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    sops-nix.url = "github:Mic92/sops-nix";

    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, ... }:
    let
      lib = nixpkgs.lib.extend (final: prev: {
        my = import ./lib {
          inherit inputs;
          lib = prev;
        };
      });

      systems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      hosts = {
        "C02GH2V9MD6M" = lib.my.mkHostConfig {
          hostname = "C02GH2V9MD6M";
          system = "x86_64-darwin";
          username = "gunwant.jain1";
          remoteBuild = false;
        };

        "mintaka" = lib.my.mkHostConfig {
          hostname = "mintaka";
          system = "x86_64-linux";
          username = "wantguns";
          remoteBuild = true;
          ips = { private = "192.168.1.130"; };
        };

        "bellatrix" = lib.my.mkHostConfig {
          hostname = "bellatrix";
          system = "aarch64-linux";
          username = "wantguns";
          remoteBuild = true;
          ips = { public = "152.67.6.204"; };
        };

        "alnitak" = lib.my.mkHostConfig {
          hostname = "alnitak";
          system = "x86_64-linux";
          username = "wantguns";
          remoteBuild = true;
          ips = { public = "78.46.83.190"; };
        };
      };

      forAllHosts = f: builtins.mapAttrs f hosts;

    in {
      inherit hosts;

      darwinConfigurations =
        builtins.mapAttrs (name: hostConfig: lib.my.mkHost hostConfig)
        (lib.filterAttrs (name: hostConfig: lib.my.isDarwin hostConfig.system)
          hosts);

      nixosConfigurations =
        builtins.mapAttrs (name: hostConfig: lib.my.mkHost hostConfig)
        (lib.filterAttrs (name: hostConfig: lib.my.isLinux hostConfig.system)
          hosts);

      homeConfigurations = forAllHosts lib.my.mkHomeConfig;

      apps = forAllSystems (system: {
        deploy = {
          type = "app";
          program = "${
              import ./lib/deploy.nix {
                pkgs = nixpkgs.legacyPackages.${system};
                inherit nixpkgs;
              }
            }/bin/deploy";
        };
      });
    };
}
