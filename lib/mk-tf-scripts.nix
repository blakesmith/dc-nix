{
  pkgs,
  terraformConfiguration,
  prefixText ? "",
  stateOut ? "state.json",
  parallelism ? 10
}:

let
  mkTfScript = name: text: pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [ pkgs.opentofu ];

    text = ''
      ${prefixText}
      ln -sf ${terraformConfiguration} config.tf.json
      tofu init
      ${text} --state=${stateOut}
    '';
  };

  apply = mkTfScript "apply" "tofu apply --parallelism=${toString parallelism}";
  destroy = mkTfScript "destroy" "tofu destroy --parallelism=${toString parallelism}";
in

pkgs.symlinkJoin {
  name = "terraform-scripts";
  paths = [
    apply destroy
  ];
}
