{ config
, pkgs
, home-manager
, isNotWSL ? false
, isGraphical ? true
, hasHyperland ? false
, hasGnome ? true
, ...
}:

let
  graphicalPackages = pkgs.lib.optionals isGraphical [
    # We are *not* in WSL
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
  ];

  gnomePackages = pkgs.lib.optionals (hasGnome && isGraphical) [
    # Gnome
    pkgs.gnomeExtensions.dash-to-panel
    pkgs.gnomeExtensions.night-theme-switcher
    pkgs.gnomeExtensions.appindicator
  ];

  hyperlandPackages = pkgs.lib.optionals (hasHyperland && isGraphical) [
    # Hyprland
    pkgs.libsForQt5.dolphin
    pkgs.wofi
    pkgs.waybar
  ];

  wslPackage = pkgs.lib.optionals isNotWSL [
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
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit (isWSL);
    inherit (isGraphical);
    inherit (hasHyperland);
    inherit (hasGnome);
    currentSystem = config.system;
  };
  home-manager.users.cola = { pkgs, config, ... }: rec {
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
      hyperlandPackages
      gnomePackages
      wslPackage
    ];

    # ========== Gnome config ==========


    dconf = {
      enable = isGraphical;
      settings = {
        "org/gnome/shell".enabled-extensions = [
          "dash-to-panel@jderose9.github.com"
          "nightthemeswitcher-gnome-shell-extension@rmnvgr.gitlab.com"
          "appindicatorsupport@rgcjonas.gmail.com"
        ];
        "org/gnome/desktop/wm/preferences".num-workspaces = 1;
        "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";
        "org/gnome/desktop/wm/keybindings" = {
          switch-applications = "@as []";
          switch-applications-backward = "@as []";
          switch-windows = [ "<Alt>Tab" ];
          switch-windows-backward = [ "<Shift><Alt>Tab" ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Shift><Control>Escape";
          command = "gnome-system-monitor";
          name = "Task Manager";
        };
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
      };
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
    programs.kitty.enable = isGraphical && hasHyperland;

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
