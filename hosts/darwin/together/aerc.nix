{
  config,
  lib,
  ...
}:

let
  accountsConf = "Library/Preferences/aerc/accounts.conf";

  secret = name: config.sops.secrets."email/gjain@together.ai/${name}".path;
  placeholder = name: config.sops.placeholder."email/gjain@together.ai/${name}";

  oauthParams = lib.concatStringsSep "&" [
    "token_endpoint=https://oauth2.googleapis.com/token"
    "client_id=${placeholder "client_id"}"
    "client_secret=${placeholder "client_secret"}"
  ];

  credCmd = "cat ${secret "refresh_token"}";
in
{
  programs.aerc.extraAccounts.work = {
    source = "imaps+xoauth2://gjain%40together.ai@imap.gmail.com:993?${oauthParams}";
    source-cred-cmd = credCmd;
    outgoing = "smtp+xoauth2://gjain%40together.ai@smtp.gmail.com:587?${oauthParams}";
    outgoing-cred-cmd = credCmd;
    default = "INBOX";
    from = "Gunwant Jain <gjain@together.ai>";
    cache-headers = true;
    copy-to = "Sent";
  };

  home.file.${accountsConf}.enable = lib.mkForce false;

  sops.templates."aerc-accounts" = {
    path = "${config.home.homeDirectory}/${accountsConf}";
    mode = "0600";
    content = config.home.file.${accountsConf}.text;
  };

  sops.secrets = {
    "email/gjain@together.ai/client_id" = { };
    "email/gjain@together.ai/client_secret" = { };
    "email/gjain@together.ai/refresh_token" = { };
  };
}
