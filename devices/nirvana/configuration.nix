{ config, pkgs, home-manager, ... }:

{
  # ========== Netwoking Settings ==========
  networking.hostName = "nirvana";
  networking.networkmanager.enable = true;
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [
    "db64858fed84f14c" # EpiSec network
    "159924d6302966a9" # Personal network
  ];
  services.openssh.enable = true;

  # ========== Graphical Settings ==========

  services.xserver.videoDrivers = [ "displaylink" "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.nvidia.modesetting.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # ========== Boot Settings ==========
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.defaultEntry = "auto-windows";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.bootspec.enable = true;
  boot.lanzaboote = {
    enable = false;
    pkiBundle = "/etc/secureboot";
  };

  # ========== Virtualisation Settings ==========
  virtualisation.vmware.guest.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # Fuck containers, but I need them for distrobox
  virtualisation.podman.enable = true;

  # ========== Misc Settings ==========
  system.stateVersion = "22.11";
  nixpkgs.config.allowUnfree = true;
}

