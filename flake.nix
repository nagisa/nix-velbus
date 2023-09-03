{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-utils.url = "github:numtide/flake-utils";
        python-velbustcp = { url = "github:velbus/python-velbustcp"; flake = false; };
    };
    description = "Run a Velbus TCP gateway on your NixOS system";

    outputs = { self, flake-utils, ... }@inputs: (flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import inputs.nixpkgs { inherit system; };
    in {
        packages = with pkgs.python3Packages; rec {
            blinker = buildPythonPackage rec {
                pname = "blinker";
                version = "1.6.1";
                src = fetchPypi {
                    inherit pname version;
                    hash = "sha256-Ld+iI0g86PJOzScj4OJ81DiO8ZvvHXawmj2ukwM9sjE=";
                };
                format = "pyproject";
                buildInputs = [ setuptools ];
                propagatedBuildInputs = [ typing-extensions ];
            };
            default = buildPythonApplication rec {
                pname = "python-velbustcp";
                version = inputs.python-velbustcp.shortRev;
                format = "pyproject";
                src = inputs.python-velbustcp;
                buildInputs = [ setuptools ];
                propagatedBuildInputs = [ pyserial blinker ];
            };
        };

        apps.default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/velbustcp";
        };

    })) // {
        nixosModules.default = { config, lib, pkgs, ... }:
        with lib;
        let cfg = config.services.velbustcp;
        in {
            options.services.velbustcp = {
                enable = mkEnableOption "Enable the Velbus TCP Gateway service.";
                package = mkOption {
                    description = "The `python-velbustcp` package to use";
                    type = types.package;
                    default = self.packages.${pkgs.system}.default;
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
                systemd.services.velbustcp = {
                    description = "Velbus TCP Gateway";
                    wants = [ "network.target" ];
                    wantedBy = [ "multi-user.target" ];
                    serviceConfig = {
                        Restart = lib.mkDefault "on-failure";
                        ExecStart = "${cfg.package}/bin/velbustcp --settings=${pkgs.writeText "velbustcp-settings.json" (builtins.toJSON cfg.settings)}";
                    };
                };
            };
        };
    };
}
