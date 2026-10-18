{ pkgs, ... }:

{
  systemd.services.fix-user-runtime-dir = {
    description = "Fix /run/user/1000 ownership for WSL";
    wantedBy = [ "user@1000.service" ];
    before = [ "user@1000.service" ];
    after = [ "user-runtime-dir@1000.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/chown -R cino:users /run/user/1000";
      RemainAfterExit = true;
    };
  };
}
