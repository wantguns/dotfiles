{ config, pkgs, lib, ... }:

let cfg = config.features; in

lib.mkIf cfg.aerc {
  programs.aerc = {
    enable = true;
    extraAccounts = {
      spam = {
        source = "imaps://gunwant2012@gmail.com@imap.gmail.com:993";
        source-cred-cmd = "cat ${config.sops.secrets."email/gunwant2012@gmail.com/source".path}";
        outgoing = "smtps+plain://gunwant2012@gmail.com@smtp.gmail.com:465";
        outgoing-cred-cmd = "cat ${config.sops.secrets."email/gunwant2012@gmail.com/outgoing".path}";
        default = "INBOX";
        from = "Gunwant Jain <gunwant2012@gmail.com>";
        cache-headers = true;
        copy-to = "Sent";
      };
      void = {
        source = "imaps://void@wantguns.dev@imap.migadu.com";
        source-cred-cmd = "cat ${config.sops.secrets."email/void@wantguns.dev/source".path}";
        outgoing = "smtps://void@wantguns.dev@smtp.migadu.com";
        outgoing-cred-cmd = "cat ${config.sops.secrets."email/void@wantguns.dev/source".path}";
        default = "INBOX";
        from = "Gunwant Jain <void@wantguns.dev>";
        cache-headers = true;
        copy-to = "Sent";
      };
      real = {
        source = "imaps://therealgunwant@gmail.com@imap.gmail.com:993";
        source-cred-cmd = "cat ${config.sops.secrets."email/therealgunwant@gmail.com/source".path}";
        outgoing = "smtps+plain://therealgunwant@gmail.com@smtp.gmail.com:465";
        outgoing-cred-cmd = "cat ${config.sops.secrets."email/therealgunwant@gmail.com/outgoing".path}";
        default = "INBOX";
        from = "Gunwant Jain <therealgunwant@gmail.com>";
        cache-headers = true;
        copy-to = "Sent";
      };
      work = {
        source = "imaps://mail@wantguns.dev@imap.migadu.com";
        source-cred-cmd = "cat ${config.sops.secrets."email/mail@wantguns.dev/source".path}";
        outgoing = "smtps://mail@wantguns.dev@smtp.migadu.com";
        outgoing-cred-cmd = "cat ${config.sops.secrets."email/mail@wantguns.dev/outgoing".path}";
        default = "INBOX";
        from = "Gunwant Jain <mail@wantguns.dev>";
        cache-headers = true;
        copy-to = "Sent";
      };
    };
    extraConfig = {
      general = {
        "unsafe-accounts-conf" = true;
      };
      compose = {
        "reply-to-self" = false;
      };
      ui = {
        "threading-enabled" = true;
        "column-subject" = "{{.ThreadPrefix}}{{if .ThreadFolded}}{{printf \"{%d}\" .ThreadCount}}{{end}}{{.Subject}}";
      };
      filters = {
        "text/plain" = "colorize";
        "text/calendar" = "calendar";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
        "text/html" = "html | colorize";
        "image/*" = "catimg -w $(tput cols) -";
      };
    };
  };

  sops.secrets = {
    "email/gunwant2012@gmail.com/source" = {};
    "email/gunwant2012@gmail.com/outgoing" = {};
    "email/void@wantguns.dev/source" = {};
    "email/void@wantguns.dev/outgoing" = {};
    "email/therealgunwant@gmail.com/source" = {};
    "email/therealgunwant@gmail.com/outgoing" = {};
    "email/mail@wantguns.dev/source" = {};
    "email/mail@wantguns.dev/outgoing" = {};
  };
}
