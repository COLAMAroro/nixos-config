{ config, pkgs, home-manager, ... }:

{
  # ========== Netwoking Settings ==========
  networking.hostName = "thoth";
  networking.networkmanager.enable = true;
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [
    "159924d6302966a9" # Personal network
  ];
  services.openssh.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 21 22 80 443 4533 8123 ];
  networking.firewall.allowedUDPPorts = [ 21 22 80 443 4533 8123 ];

  # ========== Boot Settings ==========
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ========== Virtualisation Settings ==========

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;

  # ========== (S)FTP User Settings ==========

  systemd.tmpfiles.rules = [
    "d /var/media 0770 mediashare mediashare"
    "d /var/media/Music 0770 mediashare mediashare"
  ];
  users.groups.mediashare.name = "mediashare";
  users.users.mediashare = {
    isSystemUser = true;
    home = "/var/media";
    createHome = false; # Ensured via tmpfiles.rules
    initialPassword = "mediashare";
    group = "mediashare";
  };

  # ========== User Settings ==========

  users.users.cola.extraGroups = [ "mediashare" ];
  users.users.mykado = {
    isNormalUser = true;
    initialPassword = "Mykado";
    extraGroups = [ "mediashare" "wheel" ];
    shell = pkgs.zsh;
  };

  # home-manager.users.cola = { pkgs, config, lib, home, ... }: {
  #   home.activation = {
  #     linkMedia = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #       [ -d /var/media ] && [ ! -L ${home.homeDirectory}/media ] &&
  #       mkdir -p ${home.homeDirectory}/media &&
  #       ln -s /var/media ${home.homeDirectory}/media
  #     '';
  #   };
  # };

  # ========== FTP Share Settings ==========

  services.vsftpd.enable = true;
  services.vsftpd.userlist = [
    "cola"
    "mediashare"
  ];
  services.vsftpd.writeEnable = true;
  services.vsftpd.localUsers = true;

  # ========== Reverse Proxy settings ==========

  services.caddy = {
    enable = true;
    acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory"; # Temporary, for staging tests
    virtualHosts."http://thoth.snek.network" = {
      hostName = "http://thoth.snek.network";
      extraConfig = ''
        reverse_proxy /music localhost:4533
        respond / "Hi"
      '';
    };
    globalConfig = ''
      debug
      auto_https disable_redirects
    '';
  };

  # ========== Home Assistant Settings ==========

  virtualisation.oci-containers.containers.homeassistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    volumes = [
      "homeassistantConfig:/config"
    ];
    environment = {
      "TZ" = "Europe/Paris";
    };
    extraOptions = [
      "--privileged"
      "--network=host"
    ];
    ports = [ "8123:8123" ];
  };

  # ========== Misc Settings ==========

  virtualisation.oci-containers.backend = "docker";
  system.stateVersion = "22.11";
  nixpkgs.config.allowUnfree = true;
}

