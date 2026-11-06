{
    description = "Run a Velbus TCP gateway on your NixOS system";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
        python-velbustcp = { url = "github:velbus/python-velbustcp"; flake = false; };
    };

    outputs = { self, flake-utils, ... }@inputs: rec {
        overlay = final: prev: rec {
            velbustcp-blinker = final.python3Packages.callPackage ./blinker.nix {};
            velbustcp-pyserial-asyncio-fast = final.python3Packages.callPackage ./pyserial-asyncio-fast.nix {};
            velbustcp = final.python3Packages.callPackage ./python-velbustcp.nix {
                src = inputs.python-velbustcp;
                pyserial-asyncio-fast = velbustcp-pyserial-asyncio-fast;
            };
        };

        nixosModules.default = { config, lib, pkgs, ... }:
        let
            cfg = config.services.velbustcp;
        in with lib; {
            options.services.velbustcp = {
                enable = mkEnableOption "Enable the Velbus TCP Gateway service.";
                package = mkOption {
                    description = "The `python-velbustcp` package to use";
                    type = types.package;
                    default = pkgs.velbustcp;
                };
                settings = mkOption {
                    description = ''
                        python-velbustcp configuration as a nix attribute set.

                        See the template configuration file for the options available:
                        https://github.com/velbus/python-velbustcp/blob/master/settings.json.template
                    '';
                    default = { };
                    type = types.submodule {
                        freeformType = (pkgs.formats.json {}).type;
                    };
                };

            };

            config = mkIf cfg.enable {
                nixpkgs.overlays = [ overlay ];
                systemd.services.velbustcp = {
                    description = "Velbus TCP Gateway";
                    # It is possible to specify specific IP addresses you want to bind to, and
                    # binding may fail somewhat silently (the service will continue running.)
                    wants = [ "network.target" ];
                    wantedBy = [ "multi-user.target" ];
                    serviceConfig = {
                        Restart = "on-failure";
                        ExecStart = "${cfg.package}/bin/velbustcp --settings=${pkgs.writeText "velbustcp-settings.json" (builtins.toJSON cfg.settings)}";
                        DynamicUser = true;
                        # To access ttyACM/ttyUSB.
                        SupplementaryGroups = [ "dialout" ];
                        DevicePolicy = "closed";
                        DeviceAllow = [ "char-ttyACM rw" "char-ttyUSB rw" ];
                        CapabilityBoundingSet = "";
                        NoNewPrivileges = true;
                        ProtectKernelTunables = true;
                        ProtectKernelModules = true;
                        ProtectKernelLogs = true;
                        ProtectControlGroups = true;
                        ProtectClock = true;
                        ProtectHostname = true;
                        ProtectProc = "invisible";
                        ProcSubset = "pid";
                        PrivateUsers = true;
                        LockPersonality = true;
                        RestrictRealtime = true;
                        RestrictNamespaces = true;
                        UMask = "0077";
                        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
                        SystemCallArchitectures = "native";
                        SystemCallFilter = [ "@system-service" "~@privileged @resources" ];
                    };
                };
            };
        };
    } // flake-utils.lib.eachDefaultSystem (system: {
        packages = with import inputs.nixpkgs { inherit system; overlays = [ self.overlay ]; }; {
            inherit velbustcp velbustcp-blinker;
        };
        apps.velbustcp = {
            type = "app";
            program = "${self.packages.${system}.velbustcp}/bin/velbustcp";
        };
    });
}
