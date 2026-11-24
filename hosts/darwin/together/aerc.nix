{
  config,
  lib,
  pkgs,
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
  oauthConfig = pkgs.writeText "work-mail-oauth.json" (
    builtins.toJSON {
      accounts.work.oauth = builtins.listToAttrs (
        map
          (name: {
            inherit name;
            value = secret name;
          })
          [
            "client_id"
            "client_secret"
            "refresh_token"
          ]
      );
    }
  );
in
lib.mkIf config.features.aerc {
  programs.mbsync.package = pkgs.isync.override { withCyrusSaslXoauth2 = true; };
  accounts.email.accounts.work = {
    address = "gjain@together.ai";
    realName = "Gunwant Jain";
    folders.inbox = "INBOX";
    userName = "gjain@together.ai";
    passwordCommand = "${config.home.profileDirectory}/bin/mail-oauth ${oauthConfig} work";
    imap = {
      host = "imap.gmail.com";
      port = 993;
      tls.enable = true;
    };
    mbsync = {
      enable = true;
      create = "maildir";
      patterns = [
        "INBOX"
        "[Gmail]/All Mail"
        "[Gmail]/Sent Mail"
        "[Gmail]/Drafts"
      ];
      extraConfig.account.AuthMechs = "XOAUTH2";
      extraConfig.channel = {
        Sync = [
          "PullNew"
          "PullFlags"
          "PushNew"
          "PushFlags"
        ];
        MaxMessages = 0;
        CopyArrivalDate = true;
      };
    };
  };

  programs.aerc.extraAccounts.work = {
    outgoing = "smtp+xoauth2://gjain%40together.ai@smtp.gmail.com:587?${oauthParams}";
    outgoing-cred-cmd = credCmd;
    default = "INBOX";
    from = "Gunwant Jain <gjain@together.ai>";
    copy-to = "";
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
