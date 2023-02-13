{ config, pkgs, home-manager, isNotWSL ? true, ... }:

let
  # Temporary fix for tests in kitty. Awaiting the release in nixos-unstable
  kittyNixpkgs = import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/c28f3f4bb3c1b7c723c1bf9e012704d89888aeff.tar.gz";
      sha256 = "sha256:01arj6fl4d3074lsayw8yjgh4fxg0mcz98znc87gl0v3bxq7bi6x";
    })
    { system = "x86_64-linux"; };
  plateformSpecificPackages =
    if (isNotWSL)
    then [
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

      # Gnome
      pkgs.gnomeExtensions.dash-to-panel
      pkgs.gnomeExtensions.night-theme-switcher
      pkgs.gnomeExtensions.appindicator

      # Hyprland
      pkgs.libsForQt5.dolphin
      pkgs.wofi
      pkgs.waybar
    ]
    else [
      # We *are* in WSL
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
  home-manager.extraSpecialArgs = { inherit (isWSL); currentSystem = config.system; };
  home-manager.users.cola = { pkgs, config, ... }: rec {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "cola";
    home.homeDirectory = "/home/cola";

    xdg.enable = true;
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };

    nixpkgs.config.allowUnfree = true;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "22.11";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    dconf = {
      enable = isNotWSL;
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

    home.packages = commonPackages ++ plateformSpecificPackages;

    programs.fish.enable = true;
    programs.fish.shellInit = builtins.readFile ./fish/shellInit.fish;
    programs.fish.shellAliases = {
      cls = "clear";
      cat = "bat";
      nshell = "nix-shell -p";
    };

    programs.bash.enable = true;
    programs.bash.initExtra = builtins.readFile ./bash/bashrc;
    programs.bash.shellAliases = programs.fish.shellAliases;

    programs.bat.enable = true;

    programs.gh.enable = true;
    programs.micro.enable = true;
    programs.htop.enable = isNotWSL;
    programs.navi.enable = true;
    programs.tealdeer.enable = true;

    programs.kitty.enable = true;
    programs.kitty.package = kittyNixpkgs.kitty;

    programs.nnn.enable = true;
    programs.nnn.package = pkgs.nnn.override ({ withNerdIcons = true; });
    programs.nnn.extraPackages = with pkgs; [ ffmpegthumbnailer mediainfo sxiv ];

    programs.rbw = {
      enable = isNotWSL;
      settings = {
        email = emailInfo.email;
        lock_timeout = 300;
        pinentry = "gnome3";
        base_url = "https://vault.bitwarden.com";
      };
    };

    services.mpris-proxy.enable = isNotWSL;

    home.sessionVariables = {
      MOZ_WAYLAND =
        if (builtins.getEnv "XDG_SESSION_TYPE" == "wayland" && isNotWSL)
        then 1 else 0;
      EDITOR = "micro";
    };

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
