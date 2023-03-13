{ config
, pkgs
, home-manager
, isNotWSL ? true
, isGraphical ? true
, hasHyprland ? false
, hasGnome ? true
, nixpkgs
, ...
}:

let
  graphicalPackages = pkgs.lib.optionals isGraphical [
    # Grahical environments
    pkgs.teams
    pkgs.discord
    pkgs.vscode
    pkgs.clip
    pkgs.remmina
    pkgs.steamcmd
    pkgs.steam-tui
    pkgs.steam
    pkgs.vivaldi
    pkgs.vivaldi-ffmpeg-codecs
    (pkgs.lutris.override {
      extraLibraries = pkgs: with pkgs; [
        jansson
      ];
      steamSupport = false;
    })
  ];

  gnomePackages = pkgs.lib.optionals (hasGnome && isGraphical) [
    # Gnome
    pkgs.gnomeExtensions.dash-to-panel
    pkgs.gnomeExtensions.night-theme-switcher
    pkgs.gnomeExtensions.appindicator
  ];

  hyprlandPackages = pkgs.lib.optionals (hasHyprland && isGraphical) [
    # Hyprland
    pkgs.libsForQt5.dolphin
    pkgs.wofi
    pkgs.waybar
  ];

  wslPackage = pkgs.lib.optionals (!isNotWSL) [
    pkgs.wslu
  ];

  commonPackages = [
    pkgs.fish
    pkgs.openssh
    pkgs.file
    pkgs.powershell
    pkgs.rnix-lsp
    pkgs.any-nix-shell
    pkgs.unzip
    pkgs.xclip
  ];
  bwSecrets = builtins.import ./bw.nix;
  emailInfo = builtins.import ./smtpCredentials.nix;
in
{
  users.users.cola = {
    isNormalUser = true;
    initialPassword = "COLA2023";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [
      ./id_rsa.pub
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit (isNotWSL);
    inherit (isGraphical);
    inherit (hasHyprland);
    inherit (hasGnome);
    nixpkgsOutPath = nixpkgs.outPath;
    currentSystem = config.system;
  };
  home-manager.users.cola = { pkgs, config, nixpkgsOutPath, ... }: rec {
    # ========== Home Manager Settings ==========
    home.stateVersion = "22.11";
    home.username = "cola";
    home.homeDirectory = "/home/cola";
    programs.home-manager.enable = true;

    # ========== General Settings ==========
    xdg.enable = true;
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };

    nixpkgs.config.allowUnfree = true;

    # ========== Packages ==========
    home.packages = pkgs.lib.flatten [
      commonPackages
      graphicalPackages
      hyprlandPackages
      gnomePackages
      wslPackage
    ];

    # ========== Registry Settings ==========
    # Following the tips from https://ayats.org/blog/channels-to-flakes (Thanks!)
    xdg.configFile."nix/inputs/nixpkgs".source = nixpkgsOutPath;
    home.sessionVariables.NIX_PATH = "nixpkgs=${config.xdg.configHome}/nix/inputs/nixpkgs$\{NIX_PATH:+:$NIX_PATH}";

    # ========== Gnome config ==========
    dconf = {
      enable = isGraphical;
      settings = import ./dconf.nix;
    };

    # ========== Shell config ==========
    home.shellAliases = {
      cls = "clear";
      cat = "bat";
      nshell = "nix-shell -p";
    };

    programs.fish.enable = true;
    programs.fish.shellInit = builtins.readFile ./fish/shellInit.fish;
    programs.bash.enable = true;
    programs.bash.initExtra = builtins.readFile ./bash/bashrc;
    programs.bat.enable = true;

    programs.micro.enable = true;
    home.sessionVariables = {
      EDITOR = "micro";
    };

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    # ========== Git config ==========

    programs.git = {
      enable = true;
      aliases = {
        tree = "log --all --decorate --oneline --graph";
        pall = "push --all";
      };
      userEmail = "github@rondier.io";
      userName = "COLAMAroro";
      extraConfig = {
        sendemail = emailInfo;
        init.defaultBranch = "main";
      };
      package = pkgs.gitFull;
    };
    programs.gh.enable = true;

    # ========== Additional features ==========
    programs.htop.enable = isNotWSL;
    programs.navi.enable = true;
    programs.tealdeer.enable = true;
    programs.kitty.enable = isGraphical && hasHyprland;

    programs.nnn.enable = true;
    programs.nnn.package = pkgs.nnn.override ({ withNerdIcons = true; });
    programs.nnn.extraPackages = with pkgs; [ ffmpegthumbnailer mediainfo sxiv ];

    programs.rbw = {
      enable = isGraphical;
      settings = {
        email = emailInfo.email;
        lock_timeout = 300;
        pinentry = "gnome3";
        base_url = "https://vault.bitwarden.com";
      };
    };

    services.mpris-proxy.enable = isGraphical;

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.configHome}/gnupg";
    };
    services.gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };
}
