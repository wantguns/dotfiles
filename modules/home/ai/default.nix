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
        defaultModel = "claude-opus-5-5";
        defaultThinkingLevel = "medium";
        skills = [
          "~/.claude/skills"
          "~/.codex/skills"
          "${humanizer-src}"
        ]
        ++ cfg.extraSkills;
        packages = [
          "npm:@termdraw/pi@0.4.1"
          "npm:pi-web-access@0.28.0"
          "npm:pi-mcp-adapter@2.32.1"
          "npm:context-mode@1.0.169"
          "git:github.com/obra/superpowers@v6.3.0"
          "git:github.com/DietrichGebert/ponytail@v4.9.0"
        ];
        theme = "moonfly";
      };
    };

    # auth.json cannot be a store symlink: pi writes OAuth tokens into it on
    # /login and refreshes them in place. So merge the anthropic entry in on
    # each switch instead, leaving any provider pi added untouched.
    home.activation.piAuthJson = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      auth="$HOME/.pi/agent/auth.json"
      mkdir -p "$(dirname "$auth")"

      # drop the symlink left by the previous declarative setup
      if [ -L "$auth" ]; then rm -f "$auth"; fi
      if [ ! -s "$auth" ]; then echo '{}' > "$auth"; fi

      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq \
           --arg k '!cat ${config.sops.secrets."ai_api/claude_pi_together".path}' \
           '.anthropic = {type: "api_key", key: $k}' "$auth" > "$tmp"; then
        mv "$tmp" "$auth"
        chmod 600 "$auth"
      else
        rm -f "$tmp"
        echo "pi auth.json: jq merge failed, leaving existing file alone" >&2
      fi
    '';

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
        };
        notion = {
          url = "https://mcp.notion.com/mcp";
          auth = "oauth";
        };
        grafana = {
          url = "https://mcp.grafana.com/mcp";
          auth = "oauth";
          headers = {
            "X-Grafana-URL" = "https://togetherai.grafana.net";
          };
        };
      };
    };
  })
]
