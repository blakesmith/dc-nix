{ lib, ... }:

{
  options.dc.region.incus = {
    project = lib.mkOption {
      type = lib.types.str;
      description = "Project to create resources in";
      default = "default";
    };

    remoteApiHost = lib.mkOption {
      type = lib.types.str;
      description = "Incus remote API address";
      example = "10.1.1.8";
    };

    defaultImage = lib.mkOption {
      type = lib.types.str;
      description = "Default incus image";
      default = "images:nixos/unstable";
    };
  };

  options.dc.region = {
    identifier = lib.mkOption {
      type = lib.types.str;
      description = "Region identifier";
      example = "local";
    };

    machineManager = lib.mkOption {
      type = lib.types.enum [ "incus" ];
      description = "Machine manager / API";
      example = "incus";
      default = "incus";
    };

    dnsZones = lib.mkOption {
      description = "Attrs of DNS zones";
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "DNS Zone name";
            example = "example.com";
          };

          provider = lib.mkOption {
            type = lib.types.enum [ "manual" "route53" "digitalocean" ];
            description = "DNS provider: How the DNS zone is hosted / provisioned";
            default = "manual";
            example = "route53";
          };
        };
      });
      default = {};
    };

    httpEndpoints = lib.mkOption {
      description = "HTTP Endpoints that get exposed via DNS and HTTP vhosts";
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          address = lib.mkOption {
            description = "HTTP / DNS Address of the endppoint";
            type = lib.types.str;
            example = "api.example.com";
          };

          nginx = lib.mkOption {
            description = "Nginx options to pass to the endpoint virtualhost";
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                root = lib.mkOption {
                  description = "nginx virtualhost root";
                  type = lib.types.nullOr (lib.types.path);
                  example = "/usr/share/web_root";
                  default = null;
                };

                proxyPass = lib.mkOption {
                  description = "nginx virtualhost proxyPass configuration";
                  type = lib.types.nullOr (lib.types.str);
                  example = "http://127.0.0.1:4333";
                  default = null;
                };
              };
            });
          };

          dns = lib.mkOption {
            description = "DNS Options for the endpoint";
            type = lib.types.nullOr (lib.submodule {
              options = {
                records = lib.mkOption {
                  description = "Array of DNS A records to provision for the endpoint";
                  type = lib.types.listOf (lib.types.str);
                  example = [ "10.0.0.1" ];
                  default = [];
                };
              };
            });
          };
        };
      });

      default = {};
    };

    hosts = lib.mkOption {
      description = "List of hosts and their respective host information";
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          ipv4Address = lib.mkOption {
            type = lib.types.nullOr (lib.types.str);
            description = "IPv4 address of the host. Can be null during provisioning";
            default = null;
            example = "10.0.0.2";
          };

          provisioner = lib.mkOption {
            type = lib.types.enum [ "none" "terraform" ];
            description = "Method that provisions the host / machine";
            default = "none";
            example = "terraform";
          };
        };
      });
      default = {};
      example = {
        web01 = {
          ipv4Address = "10.0.0.1";
        };
      };
    };
  };
}
