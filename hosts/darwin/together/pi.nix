{ config, lib, ... }:
{
  config = lib.mkIf config.features.ai.pi {
    features.ai.extraSkills = [
      "${config.home.homeDirectory}/dev/together/tcloud-knowledge-base/pi-skills"
    ];

    home.file.".pi/agent/mcp.json".text = builtins.toJSON {
      mcpServers = {
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
