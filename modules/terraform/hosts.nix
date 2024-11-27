{ config, lib, ... }:

with builtins;

let
  mapAttrsFilter = m: pred: attrs:
    (listToAttrs (map m (filter pred (lib.attrsets.attrsToList attrs))));

  hostResources = {
    resource.incus_instance = (mapAttrsFilter
      (hostAndValue:
        {
          name = hostAndValue.name;
          value = {
            name = hostAndValue.name;
            image = config.dc.region.incus.defaultImage;
            project = config.dc.region.incus.project;
            profiles = [ "default" ];
            type = "virtual-machine";

            config = {
              "security.secureboot" = false;
            };
          };
        })
      (hostAndValue:
        ((builtins.hasAttr "provisioner" hostAndValue.value) && hostAndValue.value.provisioner == "terraform"))
      config.dc.region.hosts);
  };

  cfg = config.dc.terraform.hosts;
in

{
  options.dc.terraform.hosts = {
    enable = lib.mkEnableOption "Enable terraform host provisioning";
  };

  config = lib.mkIf cfg.enable (lib.attrsets.recursiveUpdate hostResources {
    resource.incus_profile.default = {
      name = "default";
      project = config.dc.region.incus.project;

      config = {
        "limits.memory" = "2GB";
      };

      device = [
        {
          name = "eth0";
          type = "nic";
          properties = {
            name = "eth0";
            nictype = "bridged";
            parent = "incusbr0";
          };
        }
        {
          name = "root";
          type = "disk";
          properties = {
            path = "/";
            pool = "default";
            size = "35GiB";
          };
        }
      ];
    };
  });
}
