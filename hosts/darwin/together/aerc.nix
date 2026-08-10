{
  config,
  pkgs,
  ...
}:

let
  secret = name: config.sops.secrets."email/gjain@together.ai/${name}".path;

  tokenCmd = builtins.concatStringsSep " " [
    "${pkgs.curl}/bin/curl -s https://oauth2.googleapis.com/token"
    ''--data-urlencode "client_id=$(cat ${secret "client_id"})"''
    ''--data-urlencode "client_secret=$(cat ${secret "client_secret"})"''
    ''--data-urlencode "refresh_token=$(cat ${secret "refresh_token"})"''
    ''--data-urlencode "grant_type=refresh_token"''
    "| ${pkgs.jq}/bin/jq -r .access_token"
  ];
in
{
  programs.aerc.extraAccounts.work = {
    source = "imaps+xoauth2://gjain%40together.ai@imap.gmail.com:993";
    source-cred-cmd = tokenCmd;
    outgoing = "smtp+xoauth2://gjain%40together.ai@smtp.gmail.com:587";
    outgoing-cred-cmd = tokenCmd;
    default = "INBOX";
    from = "Gunwant Jain <gjain@together.ai>";
    cache-headers = true;
    copy-to = "Sent";
  };

  sops.secrets = {
    "email/gjain@together.ai/client_id" = { };
    "email/gjain@together.ai/client_secret" = { };
    "email/gjain@together.ai/refresh_token" = { };
  };
}
