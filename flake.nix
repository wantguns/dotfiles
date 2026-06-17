{
  description = "Nix System Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko/latest";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    sops-nix.url = "github:Mic92/sops-nix";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";

    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      darwin,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib.extend (
        final: prev: {
          my = import ./lib {
            inherit inputs;
            lib = prev;
          };
        }
      );

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
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
          ips = {
            private = "192.168.0.130";
            orion = {
              address = "10.69.0.3";
              gateway = "bellatrix";
              publicKey = "U6ePNi8mX6KbE/p8e1xip2JkGjdIGWqIvnxSDL8MFg0=";
              privateKeyFile = "/run/secrets/wg/mintaka/private";
            };
          };
        };

        "bellatrix" = lib.my.mkHostConfig {
          hostname = "bellatrix";
          system = "aarch64-linux";
          username = "wantguns";
          remoteBuild = true;
          ips = {
            public = "152.67.3.218";
            orion = {
              address = "10.69.0.2";
              publicKey = "h8gz2dL5bESUFaBshKZdkDXZYi1Nt/T4X04nVNBIygA=";
              privateKeyFile = "/run/secrets/wg/bellatrix/private";
            };
          };
        };

        "alnitak" = lib.my.mkHostConfig {
          hostname = "alnitak";
          system = "x86_64-linux";
          username = "wantguns";
          remoteBuild = true;
          ips = {
            public = "78.46.83.190";
            orion = {
              address = "10.69.0.1";
              publicKey = "5pvq7XBbZ59aeJsCtc6r0wpet3z2sFyp1M/TQaXJqlc=";
              privateKeyFile = "/run/secrets/wg/alnitak/private";
            };
          };
        };

        "meissa" = lib.my.mkHostConfig {
          hostname = "meissa";
          system = "aarch64-darwin";
          username = "wantguns";
          remoteBuild = false;
        };

        "rigel" = lib.my.mkHostConfig {
          hostname = "rigel";
          system = "x86_64-linux";
          username = "wantguns";
          remoteBuild = false;
          ips = {
            orion = {
              address = "10.69.0.5";
              gateway = "bellatrix";
              publicKey = "wGO+NOi86UaAp1x9RlpojaYXGAlDjThK1sxhZPLVSnI=";
              # will fail for now as the seed key is not present on rigel
              privateKeyFile = "/run/secrets/wg/rigel/private";
            };
          };
        };
      };

      extraWgHosts = {
        "shiba" = {
          hostname = "shiba";
          ips = {
            orion = {
              address = "10.69.0.10";
              gateway = "bellatrix";
              publicKey = "fIiyno6ZKuLLa38OZ2tcs0/Gn6MvQV7Y8wzlsN1ybQw=";
              privateKeyFile = "/run/secrets/wg/shiba/private";
            };
          };
        };

        "meissa" = {
          hostname = "meissa";
          ips = {
            orion = {
              address = "10.69.0.4";
              gateway = "bellatrix";
              publicKey = "vRTc+GClR3/TbRHiJUzZEHWwY7fYOWfcQ78ZdczH4g4=";
              privateKeyFile = "/run/secrets/wg/meissa/private";
            };
          };
        };

        "pyco" = {
          hostname = "pyco";
          ips = {
            orion = {
              address = "10.69.0.240";
              gateway = "bellatrix";
              publicKey = "gnqKE+4medjdlrwILRw2IkuOqdQCn0IZRyc4xxXRmQU=";
              privateKeyFile = "/run/secrets/wg/pyco/private";
            };
          };
        };

        "ps" = {
          hostname = "ps";
          ips = {
            orion = {
              address = "10.69.0.241";
              gateway = "bellatrix";
              publicKey = "NBkzNoi4GQoiseWx5ND5IbyuaUmgpXN8B/briQb7/zA=";
              privateKeyFile = "/run/secrets/wg/ps/private";
            };
          };
        };

        "kps" = {
          hostname = "ps";
          ips = {
            orion = {
              address = "10.69.0.242";
              gateway = "bellatrix";
              publicKey = "kQXPl3IWivlFsI2tnnnV7wWvqtVEjgfnJjbwaGhCpxs=";
              privateKeyFile = "/run/secrets/wg/kps/private";
            };
          };
        };

        "wantguns-bindos" = {
          hostname = "wantguns-bindos";
          ips = {
            orion = {
              address = "10.69.0.243";
              gateway = "bellatrix";
              publicKey = "YESuRKUuLz/xVCf2JP43TvDDHt3/fcDSmnhjW6vSNHs=";
              privateKeyFile = "/run/secrets/wg/wantguns-bindos/private";
            };
          };
        };

        "lota" = {
          hostname = "lota";
          ips = {
            orion = {
              address = "10.69.0.244";
              gateway = "bellatrix";
              publicKey = "ZVBqI7QHC3XWLjLxlIAIeuvfjqzAKjJ9us6oHDUW4D0=";
              privateKeyFile = "/run/secrets/wg/lota/private";
            };
          };
        };

      };

      wgInfo = lib.my.wg.mkInfo {
        inherit hosts extraWgHosts;
      };

      forAllHosts = f: builtins.mapAttrs f hosts;

    in
    {
      inherit hosts;

      darwinConfigurations = builtins.mapAttrs (
        name: hostConfig:
        lib.my.mkHost (
          hostConfig
          // {
            specialArgs.hosts = wgInfo.wgHosts;
          }
        )
      ) (lib.filterAttrs (name: hostConfig: lib.my.isDarwin hostConfig.system) hosts);

      nixosConfigurations = builtins.mapAttrs (
        name: hostConfig:
        lib.my.mkHost (
          hostConfig
          // {
            specialArgs.hosts = wgInfo.wgHosts;
          }
        )
      ) (lib.filterAttrs (name: hostConfig: lib.my.isLinux hostConfig.system) hosts);

      homeConfigurations = forAllHosts lib.my.mkHomeConfig;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

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

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        wgInfo.buildPackages { inherit pkgs; }
      );
    };
}
