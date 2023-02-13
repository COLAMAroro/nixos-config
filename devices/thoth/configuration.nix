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
  networking.firewall.allowedTCPPorts = [ 21 22 4533 ];
  networking.firewall.allowedUDPPorts = [ 21 22 4533 ];

  # ========== Boot Settings ==========
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ========== Virtualisation Settings ==========

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;

  # ========== (S)FTP User Settings ==========

  systemd.tmpfiles.rules = [
    "d /var/media 0760 mediashare mediashare"
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

  # ========== Music Stream Settings ==========

  services.navidrome.enable = true;
  services.navidrome.settings = {
    MusicFolder = "/var/media/Music";
    FFmpegPath = "${pkgs.ffmpeg}/bin/ffmpeg";
    PasswordEncryptionKey = "WYo4WpKf7UnyS46Z";
  };

  # ========== Misc Settings ==========
  system.stateVersion = "22.11";
  nixpkgs.config.allowUnfree = true;
}

