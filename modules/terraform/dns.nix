{ config, lib, ... }:

with builtins;

let
  publicZone = config.dc.region.dnsZones.public.name;

  mapAttrsFilter = m: pred: attrs:
    (listToAttrs (map m (filter pred (lib.attrsets.attrsToList attrs))));

  hostRecords = {
    resource.aws_route53_record = (mapAttrsFilter
      (hostAndValue: {
        name = hostAndValue.name;
        value = {
          zone_id = "\${aws_route53_zone.${cfg.tfIdentifier}.zone_id}";
          name = "${hostAndValue.name}.${publicZone}";
          type = "A";
          ttl = "300";
          records = [
            hostAndValue.value.internalIpv4Address
          ];
        };
      })
      (hostAndValue: (builtins.hasAttr "internalIpv4Address" hostAndValue.value))
      config.dc.region.hosts);
  };

  endpointRecords = {
    resource.aws_route53_record = builtins.mapAttrs (name: endpoint: {
      zone_id = "\${aws_route53_zone.${cfg.tfIdentifier}.zone_id}";
      name = endpoint.address;
      type = "A";
      ttl = "300";
      records = endpoint.dns.records;
    }) config.dc.region.httpEndpoints;
  };

  cfg = config.dc.terraform.dns;
in

{
  options.dc.terraform.dns = {
    enable = lib.mkEnableOption "Enable DNS provisioning";
    tfIdentifier = lib.mkOption {
      type = lib.types.str;
      description = "Terraform identifier used to pin resources";
      default = "public-zone";
    };
  };

  config = lib.mkIf cfg.enable (lib.attrsets.recursiveUpdate (lib.attrsets.recursiveUpdate hostRecords endpointRecords) {
    resource.aws_route53_zone."${cfg.tfIdentifier}" = {
      name = config.dc.region.dnsZones.public.name;
    };
  });
}
