{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { ... }: {
    nixosModules.terraform = (import ./modules).terraform;
    nixosModules.nixos = (import ./modules).nixos;
    lib = import ./lib;
  };
}
