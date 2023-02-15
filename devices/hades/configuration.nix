{ config, pkgs, hyprland, lanzaboote, ... }:

{
  # ========== Netwoking Settings ==========
  networking.hostName = "hades";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.checkReversePath = false;
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [
    "159924d6302966a9" # Personnal network
    "db64858fed84f14c" # EpiSec network
    "a0cbf4b62acc13d7" # Aeden
  ];

  # ========== Boot Settings ==========
  boot.loader.systemd-boot.enable = true;
  boot.lanzaboote = {
    enable = false;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_5_15;
  boot.bootspec.enable = true;

  # ========== Virtualisation Settings ==========
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;
  virtualisation.lxd.enable = true;
  virtualisation.waydroid.enable = true;

  # ========== Misc Settings ==========
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "22.05"; # Did you read the comment?
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
  environment.systemPackages = [
    pkgs.virt-manager
    pkgs.sbctl
  ];
  services.udev.packages = [ pkgs.gnome.gnome-settings-daemon ];
  services.udev.extraRules = builtins.readFile ./udev.txt;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.flatpak pkgs.gnome.gnome-software ];
  services.flatpak.enable = true;
}
