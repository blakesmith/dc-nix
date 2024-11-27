{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { ... }: {
    nixosModules.dc-nix = import ./modules/default.nix;
  };
}
