{ config
, pkgs
, hyprland
, lanzaboote
, isGraphical ? true
, hasGnome ? true
, hasHyprland ? false
, nixpkgs
, ...
}:

{
  # ========== Locale Settings ==========
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkDefault "fr";
    useXkbConfig = true;
  };
  time.timeZone = "Europe/Paris";

  # ========== Graphics Settings ==========
  services.xserver = {
    enable = isGraphical;
    layout = "fr";
    displayManager.gdm.enable = isGraphical;
    desktopManager.gnome.enable = isGraphical && hasGnome;
  };
  programs.hyprland.enable = hasHyprland;

  # ========== Sound Settings ==========
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    media-session.config.bluez-monitor = {
      properties = { bluez5.codecs = [ "ldac" "aptx_hd" ]; };
      rules = [
        {
          # Matches all cards
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions = {
            "update-props" = {
              "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
              # mSBC is not expected to work on all headset + adapter combinations.
              "bluez5.msbc-support" = true;
              # SBC-XQ is not expected to work on all headset + adapter combinations.
              "bluez5.sbc-xq-support" = true;
            };
          };
        }
        {
          matches = [
            # Matches all sources
            { "node.name" = "~bluez_input.*"; }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
          ];
          actions = {
            "node.pause-on-idle" = false;
          };
        }
      ];
    };
  };

  # ========== Programs Settings ==========
  environment.systemPackages = [
    pkgs.wget
    pkgs.micro
    pkgs.git
  ] ++ pkgs.lib.optionals hasGnome [
    pkgs.gnome.adwaita-icon-theme
    pkgs.gnome.gnome-screenshot
    pkgs.gnome.gnome-tweaks
    pkgs.gnomeExtensions.dash-to-panel
    pkgs.gnomeExtensions.appindicator
  ] ++ (if isGraphical then [ pkgs.firefox ] else [ pkgs.links2 ]);

  fonts.fonts = pkgs.lib.optionals isGraphical [
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

  programs.fish.enable = true;

  # ========== Security Settings ==========
  security.sudo.enable = false;
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ "cola" ];
    keepEnv = true;
    persist = true;
  }];

  # ========== Nix Settings ==========
  nixpkgs.config.allowUnfree = true;
  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };

  # ========== Gnome Settings ==========
  programs.dconf.enable = hasGnome;
  environment.gnome.excludePackages = pkgs.lib.optionals hasGnome [
    pkgs.gnome-tour
    pkgs.gnome.gnome-characters
    pkgs.gnome.gnome-maps
    pkgs.gnome.cheese
    pkgs.gnome.epiphany
    pkgs.gnome.geary
    pkgs.gnome.totem
    pkgs.gnome.tali
    pkgs.gnome.iagno
    pkgs.gnome.hitori
    pkgs.gnome.atomix
  ];

  # ========== Registry Settings ==========
  # Following the tips from https://ayats.org/blog/channels-to-flakes (Thanks!)

  environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
  nix.registry.nixpkgs.flake = nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];

  # ========== Misc Settings ==========
  services.printing.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
