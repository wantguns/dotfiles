{
  config,
  lib,
  pkgs,
  ...
}:
let
  mailToolsSrc = builtins.fetchTree {
    type = "git";
    url = "https://git.wantguns.dev/wantguns/mail-tools";
    rev = "b7be079d279c10897bffb809cef49a17085505bf";
    narHash = "sha256-1KmmN8iFF280oQau1s5vWLFdLzPwPBAIIWUGNkGySEA=";
  };
  accounts = lib.filterAttrs (
    _: account: account.enable && account.mbsync.enable
  ) config.accounts.email.accounts;
  profilePath = name: "${config.xdg.configHome}/notmuch/${name}/config";
  toolConfig = pkgs.writeText "mail-tools.json" (
    builtins.toJSON {
      mbsync = "${config.programs.mbsync.package}/bin/mbsync";
      mbsyncConfig = "${config.xdg.configHome}/isyncrc";
      notmuch = "${pkgs.notmuch}/bin/notmuch";
      lock = "${config.xdg.cacheHome}/mail-sync/sync.lock";
      accounts = lib.mapAttrs (name: account: {
        maildir = account.maildir.absPath;
        config = profilePath name;
      }) accounts;
    }
  );
  oauthTool = pkgs.writeShellScriptBin "mail-oauth" ''
    exec ${pkgs.python3}/bin/python3 ${mailToolsSrc.outPath}/mail-tools.py "$1" oauth "$2"
  '';
  tools = pkgs.writeShellScriptBin "mail-sync" ''
    exec ${pkgs.python3}/bin/python3 ${mailToolsSrc.outPath}/mail-tools.py ${toolConfig} sync "$@"
  '';
  networkProbe =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/usr/bin/nc -z -G 5 -w 5"
    else
      "${pkgs.netcat-openbsd}/bin/nc -z -w 5";
  reachabilityChecks = lib.unique (
    lib.mapAttrsToList (
      _: account:
      networkProbe
      + " "
      + lib.escapeShellArgs [
        account.imap.host
        (toString account.imap.port)
      ]
      + " >/dev/null 2>&1"
    ) accounts
  );
  scheduledSync = pkgs.writeShellScript "mail-sync-online" ''
    if ${lib.concatStringsSep " || " reachabilityChecks}; then
      exec ${tools}/bin/mail-sync
    else
      echo "Skipping mail sync: no IMAP server reachable."
    fi
  '';
  addresses =
    name:
    "${pkgs.python3}/bin/python3 ${mailToolsSrc.outPath}/mail-tools.py ${toolConfig} addresses ${name} '%s'";
  aercDir =
    if pkgs.stdenv.hostPlatform.isDarwin && !config.xdg.enable then
      "Library/Preferences/aerc"
    else
      "${config.xdg.configHome}/aerc";
  gmailPatterns = [
    "INBOX"
    "[Gmail]/All Mail"
    "[Gmail]/Sent Mail"
    "[Gmail]/Drafts"
  ];
  personalAccount = address: host: limit: {
    inherit address;
    realName = "Gunwant Jain";
    folders.inbox = "INBOX";
    userName = address;
    passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."email/${address}/source".path}";
    imap = {
      inherit host;
      port = 993;
      tls.enable = true;
    };
    mbsync = {
      enable = true;
      create = "maildir";
      expunge = if limit == 0 then "none" else "maildir";
      patterns = if host == "imap.gmail.com" then gmailPatterns else [ "*" ];
      extraConfig.account.AuthMechs = "PLAIN";
      extraConfig.channel = {
        Sync = [
          "PullNew"
          "PullFlags"
          "PushNew"
          "PushFlags"
        ];
        MaxMessages = limit;
        ExpireUnread = limit > 0;
        CopyArrivalDate = true;
      };
    };
  };
in
lib.mkIf config.features.aerc {
  accounts.email = {
    maildirBasePath = "${config.home.homeDirectory}/Mail";
    accounts = {
      personal = (personalAccount "mail@wantguns.dev" "imap.migadu.com" 0) // {
        primary = true;
      };
      void = personalAccount "void@wantguns.dev" "imap.migadu.com" 0;
      real = personalAccount "therealgunwant@gmail.com" "imap.gmail.com" 500;
      spam = personalAccount "gunwant2012@gmail.com" "imap.gmail.com" 500;
    };
  };

  programs.mbsync.enable = true;
  home.packages = [
    tools
    oauthTool
    pkgs.notmuch
    pkgs.translate-shell
  ];

  xdg.configFile = lib.mapAttrs' (
    name: account:
    lib.nameValuePair "notmuch/${name}/config" {
      text = lib.generators.toINI { } {
        database.path = account.maildir.absPath;
        user = {
          name = account.realName;
          primary_email = account.address;
        };
        new = {
          tags = "unread;";
          ignore = ".uidvalidity;.mbsyncstate;";
        };
        maildir.synchronize_flags = true;
        search.exclude_tags = "deleted;spam;";
      };
    }
  ) accounts;

  programs.aerc.extraAccounts = lib.mapAttrs (name: account: {
    postpone = if account.imap.host == "imap.gmail.com" then "[Gmail]/Drafts" else "Drafts";
    source = "notmuch://${name}";
    check-mail = "0";
    check-mail-cmd = "${tools}/bin/mail-sync ${name}";
    check-mail-timeout = "24h";
    address-book-cmd = addresses name;
    multi-file-strategy = "act-dir";
    query-map = toString (
      pkgs.writeText "${name}-queries" ''
        All=*
        Unread=tag:unread
        Flagged=tag:flagged
      ''
    );
  }) accounts;

  home.file."${aercDir}/binds.conf".source = pkgs.runCommand "aerc-binds.conf" { } ''
    cat ${config.programs.aerc.package}/share/aerc/binds.conf > "$out"
    cat >> "$out" <<'EOF'

    [view:account=^(personal|void|real|spam)$]
    tr = :pipe ${pkgs.translate-shell}/bin/trans -show-original n -b -no-autocorrect :en<Enter>
    tn = :pipe ${pkgs.translate-shell}/bin/trans -show-original n -b -no-autocorrect nl:en<Enter>
    thr = :pipe -p ${config.programs.aerc.package}/libexec/aerc/filters/html | ${pkgs.translate-shell}/bin/trans -show-original n -b -no-autocorrect :en<Enter>
    thn = :pipe -p ${config.programs.aerc.package}/libexec/aerc/filters/html | ${pkgs.translate-shell}/bin/trans -show-original n -b -no-autocorrect nl:en<Enter>
    EOF
  '';

  systemd.user.services.mail-sync = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit.Description = "Synchronize and index local mail";
    Service = {
      Type = "oneshot";
      ExecStart = toString scheduledSync;
      UMask = "0077";
    };
  };
  systemd.user.timers.mail-sync = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit.Description = "Synchronize mail every five minutes";
    Timer = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
  launchd.agents.mail-sync = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ (toString scheduledSync) ];
      StartInterval = 300;
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/mail-sync.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/mail-sync.log";
    };
  };
}
