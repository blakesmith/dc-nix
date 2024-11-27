{
  nixos = { ... }: {
    imports = [
      ./regions
    ];
  };

  terraform = { ... }: {
    imports = [
      ./regions
      ./terraform
    ];
  };
}
