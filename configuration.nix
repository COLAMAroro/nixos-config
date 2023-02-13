{ config, pkgs, home-manager, ... }:

let
in
{
  networking.hostName = "nirvana";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkForce "fr";
    useXkbConfig = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.videoDrivers = [ "displaylink" "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.opengl.enable = true;

  services.xserver.layout = pkgs.lib.mkForce "fr";
  services.printing.enable = true;
  sound.enable = true;
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    micro
    firefox
    sbctl
    git
  ];

  fonts.fonts = [
    (pkgs.nerdfonts.override
      {
        fonts = [
          "FiraCode"
          "CascadiaCode"
          "UbuntuMono"
          "Ubuntu"
        ];
      })
    pkgs.cascadia-code
  ];
  services.openssh.enable = true;

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [
    "db64858fed84f14c" # EpiSec
    "159924d6302966a9" # COLA's Realm
  ];

  system.stateVersion = "22.11";

  nixpkgs.config.allowUnfree = true;
  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };
  boot.kernelModules = [ "nvidia" ];
  virtualisation.vmware.guest.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  services.openldap.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.defaultEntry = "auto-windows";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.bootspec.enable = true;
  boot.lanzaboote = {
    enable = false;
    pkiBundle = "/etc/secureboot";
  };
}

