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

  # ========== Boot Settings ==========
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ========== Virtualisation Settings ==========

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;

  # ========== (S)FTP User Settings ==========

  systemd.tmpfiles.rules = [
    "d /var/media 0760 media mediashare"
  ];
  users.groups.mediashare.name = "mediashare";
  users.users.mediashare = {
    isSystemUser = true;
    home = "/var/media";
    createHome = true;
    initialPassword = "mediashare";
    group = "media";
  };
  users.users.cola.extraGroups = [ "media" ];

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

  # ========== Music Stream Settings ==========

  services.navidrome.enable = true;
  services.navidrome.settings = {
    MusicFolder = "/var/ftpshare/Music";
    FFmpegPath = "${pkgs.ffmpeg}/bin/ffmpeg";
    PasswordEncryptionKey = "WYo4WpKf7UnyS46Z";
  };

  # ========== Misc Settings ==========
  system.stateVersion = "22.11";
  nixpkgs.config.allowUnfree = true;
}

