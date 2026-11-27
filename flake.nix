{
  description = "Nix System Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko/latest";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    sops-nix.url = "github:Mic92/sops-nix";
    lanzaboote.url = "github:nix-community/lanzaboote/001e560fffc8f0235e9db20ebeb4ccde0ade1caf";

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
        };

        "mintaka" = lib.my.mkHostConfig {
          hostname = "mintaka";
          system = "x86_64-linux";
          username = "wantguns";
        };

        "bellatrix" = lib.my.mkHostConfig {
          hostname = "bellatrix";
          system = "aarch64-linux";
          username = "wantguns";
        };

        "alnitak" = lib.my.mkHostConfig {
          hostname = "alnitak";
          system = "x86_64-linux";
          username = "wantguns";
        };

        "meissa" = lib.my.mkHostConfig {
          hostname = "meissa";
          system = "aarch64-darwin";
          username = "wantguns";
        };

        "together" = lib.my.mkHostConfig {
          hostname = "together";
          system = "aarch64-darwin";
          username = "wantguns";
        };

        "rigel" = lib.my.mkHostConfig {
          hostname = "rigel";
          system = "x86_64-linux";
          username = "wantguns";
        };
      };

      orion = lib.my.wg.mkOrion {
        alnitak = {
          address = "10.69.0.1";
          publicKey = "5pvq7XBbZ59aeJsCtc6r0wpet3z2sFyp1M/TQaXJqlc=";
          endpoint = "78.46.83.190";
        };
        bellatrix = {
          address = "10.69.0.2";
          publicKey = "h8gz2dL5bESUFaBshKZdkDXZYi1Nt/T4X04nVNBIygA=";
          endpoint = "152.67.3.218";
        };
        mintaka = {
          address = "10.69.0.3";
          publicKey = "U6ePNi8mX6KbE/p8e1xip2JkGjdIGWqIvnxSDL8MFg0=";
          hub = "bellatrix";
        };
        meissa = {
          address = "10.69.0.4";
          publicKey = "vRTc+GClR3/TbRHiJUzZEHWwY7fYOWfcQ78ZdczH4g4=";
          hub = "bellatrix";
        };
        rigel = {
          address = "10.69.0.5";
          publicKey = "wGO+NOi86UaAp1x9RlpojaYXGAlDjThK1sxhZPLVSnI=";
          hub = "bellatrix";
        };
        together = {
          address = "10.69.0.6";
          publicKey = "JcngR5ExmKtFjP3Ob75pW/I5fEIS6+ThVAZisyRLsm4=";
          hub = "alnitak";
        };
        shiba = {
          address = "10.69.0.10";
          publicKey = "fIiyno6ZKuLLa38OZ2tcs0/Gn6MvQV7Y8wzlsN1ybQw=";
          hub = "bellatrix";
        };
        pyco = {
          address = "10.69.0.240";
          publicKey = "gnqKE+4medjdlrwILRw2IkuOqdQCn0IZRyc4xxXRmQU=";
          hub = "bellatrix";
        };
        ps = {
          address = "10.69.0.241";
          publicKey = "NBkzNoi4GQoiseWx5ND5IbyuaUmgpXN8B/briQb7/zA=";
          hub = "bellatrix";
        };
        kps = {
          address = "10.69.0.242";
          publicKey = "kQXPl3IWivlFsI2tnnnV7wWvqtVEjgfnJjbwaGhCpxs=";
          hub = "bellatrix";
        };
        wantguns-bindos = {
          address = "10.69.0.243";
          publicKey = "YESuRKUuLz/xVCf2JP43TvDDHt3/fcDSmnhjW6vSNHs=";
          hub = "bellatrix";
        };
        lota = {
          address = "10.69.0.244";
          publicKey = "ZVBqI7QHC3XWLjLxlIAIeuvfjqzAKjJ9us6oHDUW4D0=";
          hub = "bellatrix";
        };
        parul-uu = {
          address = "10.69.0.245";
          publicKey = "qva6E7fe7955deH1ra0clTiRpJUPGJ6EWqwgzB2QQHY=";
          hub = "bellatrix";
        };
      };

    in
    {
      inherit hosts orion;

      darwinConfigurations = builtins.mapAttrs (_: lib.my.mkHost) (
        lib.filterAttrs (_: host: lib.my.isDarwin host.system) hosts
      );

      nixosConfigurations = builtins.mapAttrs (_: lib.my.mkHost) (
        lib.filterAttrs (_: host: lib.my.isLinux host.system) hosts
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      apps = forAllSystems (system: {
        wg-config = {
          type = "app";
          program = lib.getExe (
            import ./modules/network/wg-config.nix {
              inherit lib orion;
              pkgs = nixpkgs.legacyPackages.${system};
            }
          );
        };
      });
    };
}
