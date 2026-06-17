{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features.ai;

  opencode-src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v1.2.20";
    hash = "sha256-FBmF7/uwZYY/qY1252Hz+XhXdE+Qp5axySAy5Jw7XUQ=";
  };

in
lib.mkMerge [
  (lib.mkIf cfg.opencode {
    home.packages = [
      (pkgs.opencode.overrideAttrs (old: {
        version = "1.2.20-add-dir";
        src = opencode-src;
        patches = (old.patches or [ ]) ++ [
          (pkgs.fetchpatch {
            url = "https://github.com/anomalyco/opencode/pull/8943.diff";
            hash = "sha256-kdFEf6TwahpX/8qoCq4eYbP9tJwLMv/OFQxO41X341Q=";
          })
        ];
        node_modules = old.node_modules.overrideAttrs {
          src = opencode-src;
          outputHash = "sha256-OwlJRAeKnX5YMwQgaV4op40rjt5kxsP4WrOzpp9t90w=";
        };
      }))
    ];
  })

  (lib.mkIf cfg.pi {
    programs.pi-coding-agent = {
      enable = true;
      settings = {
        packages = [
          "npm:@termdraw/pi"
          "npm:pi-web-access"
          "npm:pi-mcp-adapter"
          "npm:context-mode"
          "npm:pi-subagents"
          "npm:pi-terminal-theme"
        ];
        theme = "terminal";
      };
    };
  })
]
