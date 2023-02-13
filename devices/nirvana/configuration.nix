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
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 21 22 4533 ];
  networking.firewall.allowedUDPPorts = [ 21 22 4533 ];

  # ========== Graphical Settings ==========

  services.xserver.videoDrivers = [ "displaylink" "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.opengl.enable = true;
  boot.kernelModules = [ "nvidia" ];

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
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # ========== Misc Settings ==========
  system.stateVersion = "22.11";
  nixpkgs.config.allowUnfree = true;
}

