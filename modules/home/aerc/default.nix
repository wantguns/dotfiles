{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.features;
in

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
        outgoing = "smtp://void@wantguns.dev@smtp.migadu.com:587";
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
        outgoing = "smtp://mail@wantguns.dev@smtp.migadu.com:587";
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
        "message-list-split" = "horizontal 15";
        "threading-enabled" = true;
        "styleset-name" = "green";
        "column-subject" =
          "{{.ThreadPrefix}}{{if .ThreadFolded}}{{printf \"{%d}\" .ThreadCount}}{{end}}{{.Subject}}";
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
    stylesets.green = ''
      *.selected.bg = 2
      *.selected.fg = 0

      msglist_unread.bold = true
      msglist_unread.fg = 2
      msglist_unread.selected.bold = true
      msglist_read.selected.bold = false

      msglist_deleted.dim = true
      msglist_pill.bg = 2
      msglist_pill.fg = 0

      border.bg = default
      border.fg = 2
      title.bg = 2
      title.fg = 0
      title.bold = true
      header.fg = 2
      header.bold = true

      part_mimetype.fg = 2
      selector_focused.bold = true
      selector_focused.bg = 2
      selector_focused.fg = 0

      completion_pill.bg = 2

      [viewer]
      url.underline = true
      url.fg = 2
      header.bold = true
      header.fg = 2
      diff_add.fg = 2
      diff_del.fg = 1
    '';
  };

  sops.secrets = {
    "email/gunwant2012@gmail.com/source" = { };
    "email/gunwant2012@gmail.com/outgoing" = { };
    "email/void@wantguns.dev/source" = { };
    "email/void@wantguns.dev/outgoing" = { };
    "email/therealgunwant@gmail.com/source" = { };
    "email/therealgunwant@gmail.com/outgoing" = { };
    "email/mail@wantguns.dev/source" = { };
    "email/mail@wantguns.dev/outgoing" = { };
  };
}
