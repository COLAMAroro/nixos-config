{ config, pkgs, hyprland, lanzaboote, ... }:

{
  # ========== Netwoking Settings ==========
  networking.hostName = "agni";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.checkReversePath = false;
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [
    "159924d6302966a9" # Personnal network
  ];

  # ========== Boot Settings ==========
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.kernelPackages = pkgs.linuxPackages_6_2;

  # ========== Virtualisation Settings ==========
  virtualisation.libvirtd.enable = true;

  # ========== Fingerprint settings ==========
  services.fprintd.enable = true; # USB ID 06cb:00f9 Synaptics, Inc. Fingerprint Reader | Natively supported by libfprint

  # ========== Misc Settings ==========
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "22.05"; # Did you read the comment?
  #  services.xserver.videoDrivers = [ "displaylink" "modesetting" ]; # No displaylink on kernel 6.2. I'll wait
  environment.systemPackages = [
    pkgs.virt-manager
  ];
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.flatpak pkgs.gnome.gnome-software ];
  services.flatpak.enable = true;
}
