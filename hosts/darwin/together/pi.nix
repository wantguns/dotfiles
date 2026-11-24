{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.features.ai.pi {
    features.ai.extraSkills = [
      "${config.home.homeDirectory}/dev/together/tcloud-knowledge-base/.claude/skills"
    ];

    sops.secrets."pagerduty/together_api_key" = { };
    sops.secrets."netbox/url" = { };
    sops.secrets."netbox/token" = { };

    home.file.".pi/agent/mcp.json".text = builtins.toJSON {
      mcpServers = {
        netbox = {
          command = "${pkgs.uv}/bin/uvx";
          args = [
            "--python"
            "${pkgs.python313}/bin/python3"
            "--from"
            "git+https://github.com/netboxlabs/netbox-mcp-server@8850301ab542565f37cef39c6c1523c86ec2a02e"
            "netbox-mcp-server"
          ];
          cwd = config.home.homeDirectory;
          env = {
            NETBOX_URL = "!${pkgs.coreutils}/bin/cat ${lib.escapeShellArg config.sops.secrets."netbox/url".path}";
            NETBOX_TOKEN = "!${pkgs.coreutils}/bin/cat ${lib.escapeShellArg config.sops.secrets."netbox/token".path}";
            TRANSPORT = "stdio";
            VERIFY_SSL = "true";
          };
        };
        pagerduty = {
          url = "https://mcp.pagerduty.com/mcp";
          headers.Authorization =
            "!token=$(${pkgs.coreutils}/bin/cat ${
              lib.escapeShellArg config.sops.secrets."pagerduty/together_api_key".path
            })"
            + " && printf 'Token token=%s' \"$token\"";
        };
        linear = {
          url = "https://mcp.linear.app/mcp";
        };
        notion = {
          url = "https://mcp.notion.com/mcp";
        };
        grafana = {
          url = "https://mcp.grafana.com/mcp";
          headers = {
            "X-Grafana-URL" = "https://togetherai.grafana.net";
          };
        };
      };
    };
  };
}
