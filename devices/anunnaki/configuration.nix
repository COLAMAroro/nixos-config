{ config, pkgs, home-manager, ... }:

{
  # ========== Netwoking Settings ==========
  networking.hostName = "anunnaki";
  networking.domain = "snek.network";
  networking.networkmanager.enable = true;
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [
    "159924d6302966a9" # Personal network
  ];
  services.openssh.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 21 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 21 22 80 443 ];

  # ========== Boot Settings ==========
  boot.loader.grub.enable = true;

  # ========== HTTP Settings ==========
  services.caddy = {
    enable = true;
    virtualHosts = {
      "anunnaki.snek.network" = {
        extraConfig = ''
          root = "${./http}";
          file_server
        '';
      };
    };
    acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory"; # For testing, will change if probing test
  };

  # ========== Misc Settings ==========
  system.stateVersion = "23.05";
  nixpkgs.config.allowUnfree = true;
}

