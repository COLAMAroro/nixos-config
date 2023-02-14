{ config, pkgs, home-manager, ... }:

{
  # ========== Netwoking Settings ==========
  networking.hostName = "thoth";
  networking.networkmanager.enable = true;
  services.zerotierone.enable = true;
  #services.zerotierone.joinNetworks = [
  #  "159924d6302966a9" # Personal network
  #];
  services.openssh.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 21 22 80 443 4533 ];
  networking.firewall.allowedUDPPorts = [ 21 22 80 443 4533 ];

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

  users.users.cola.extraGroups = [ "mediashare" ];
  users.users.mykado = {
    isNormalUser = true;
    initialPassword = "Mykado";
    extraGroups = [ "mediashare" "wheel" ];
    shell = pkgs.bashInteractive;
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

  # ========== Music Stream Settings ==========

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    navidrome = {
      image = "deluan/navidrome:latest";
      volumes = [
        "/var/media/Music:/music:ro"
        "navidromeData:/data"
      ];
      environment = {
        "ND_DEFAULTTHEME" = "Spotify-Ish";
        "ND_DEFAULTLANGUAGE" = "fr";
      };
      ports = [ "4533:4533" ];
    };
  };


  # ========== Misc Settings ==========
  system.stateVersion = "22.11";
  nixpkgs.config.allowUnfree = true;
}

