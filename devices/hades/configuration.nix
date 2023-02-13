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
  boot.kernelPackages = nixpkgs.linuxPackages_5_15;
  boot.bootspec.enable = true;

  # ========== Virtualisation Settings ==========
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariables = true;
  virtualisation.anbox.enable = true;

  # ========== Misc Settings ==========
  system.stateVersion = "22.05"; # Did you read the comment?
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
  environment.systemPackages = with nixpkgs; [
    pkgs.virt-manager
    pkgs.sbctl
  ];
  services.udev.packages = [ nixpkgs.gnome.gnome-settings-daemon ];
  services.udev.extraRules = builtins.readFile ./udev.txt;
  services.flatpak.enable = true;

}
