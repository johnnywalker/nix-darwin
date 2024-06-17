{
  config,
  inputs,
  pkgs,
  ...
}: {
  home-manager = {
    users = {
      johnny = import "${inputs.self}/home/johnny/${config.networking.hostName}.nix";
    };
  };

  users = {
    mutableUsers = false;
    users = {
      johnny = {
        description = "Johnny Walker";
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.johnny-password.path;
        shell = pkgs.zsh;
        extraGroups = ["networkmanager" "wheel" "docker"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK52M5lAGnnRDpjYnPPgZX9Lz5SEfvARj23ecUPSvBHX"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhL2s7nRiFBw8U0SMQPWCsaWQXc51YMP8ga81Uqm9Rx"
        ];
      };
    };
  };

  sops = {
    secrets = {
      johnny-password = {
        sopsFile = ./secrets.yaml;
        neededForUsers = true;
      };
    };
  };
}
