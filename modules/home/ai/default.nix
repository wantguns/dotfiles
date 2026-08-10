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

  humanizer-src = pkgs.fetchFromGitHub {
    owner = "blader";
    repo = "humanizer";
    tag = "v2.9.1";
    hash = "sha256-qJIMwaas5Wnz270rUbPa4E5v2GQ62SQ1rKT0jmjYhyw=";
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
    sops.secrets."ai_api/claude_pi_together" = { };

    programs.pi-coding-agent = {
      enable = true;
      context = ./pi/AGENTS.md;
      settings = {
        hideThinkingBlock = true;
        markdown.codeBlockIndent = "";
        defaultProvider = "anthropic";
        defaultModel = "claude-opus-5";
        defaultThinkingLevel = "medium";
        skills = [
          "~/.claude/skills"
          "~/.codex/skills"
          "${humanizer-src}"
        ];
        packages = [
          "npm:@termdraw/pi@0.4.1"
          "npm:pi-web-access@0.10.7"
          "npm:pi-mcp-adapter@2.10.0"
          "npm:context-mode@1.0.162"
          "npm:pi-subagents@0.28.0"
          "git:github.com/obra/superpowers@v6.1.1"
          "git:github.com/DietrichGebert/ponytail@v4.8.4"
        ];
        theme = "moonfly";
      };
    };

    home.file.".pi/agent/auth.json".text = builtins.toJSON {
      anthropic = {
        type = "api_key";
        key = "!cat ${config.sops.secrets."ai_api/claude_pi_together".path}";
      };
    };
    home.file.".pi/agent/extensions/plan-mode.ts".source = ./pi/plan-mode.ts;
    home.file.".pi/agent/extensions/quote-reply.ts".source = ./pi/quote-reply.ts;
    home.file.".pi/agent/themes/moonfly.json".source = ./pi/themes/moonfly.json;

    home.file.".pi/web-search.json" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      text = builtins.toJSON { workflow = "none"; };
    };

    home.file.".config/mcp/mcp.json".text = builtins.toJSON {
      mcpServers = {
        linear = {
          url = "https://mcp.linear.app/mcp";
          auth = "oauth";
          excludeTools = [
            "create_comment"
            "create_issue"
            "update_issue"
            "create_issue_label"
            "create_project"
            "update_project"
            "create_document"
          ];
        };
        notion = {
          url = "https://mcp.notion.com/mcp";
          auth = "oauth";
          excludeTools = [
            "notion-create-pages"
            "notion-update-page"
            "notion-move-pages"
            "notion-duplicate-page"
            "notion-create-database"
            "notion-update-data-source"
            "notion-create-view"
            "notion-create-comment"
          ];
        };
      };
    };
  })
]
