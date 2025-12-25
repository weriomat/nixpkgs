{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.borgmatic;
in
{
  port = 9996;
  extraOpts.configFile = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    default = [ "/etc/borgmatic/config.yaml" ];
    example = [
      "/etc/borgmatic/config.yaml"
      "/etc/borgmatic.d/service1.yaml"
    ];
    description = ''
      The paths to the borgmatic config files
    '';
  };

  serviceOpts = {
    serviceConfig = {
      DynamicUser = false;
      ProtectSystem = false;
      ProtectHome = lib.mkForce false;
      ExecStart = ''
        ${pkgs.prometheus-borgmatic-exporter}/bin/borgmatic-exporter run \
          --port ${toString cfg.port} \
          --config ${lib.concatMapStringsSep ":" (f: toString f) cfg.configFile} \
          ${lib.concatMapStringsSep " " (f: lib.escapeShellArg f) cfg.extraFlags}
      '';
    };
  };
}
