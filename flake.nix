{
  description = "NixOS Configuration for workstation";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote.url = "github:nix-community/lanzaboote"; # Lanzaboote is currently unused, as support for dual-boot is *janky*
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, hyprland, ... }@inputs:
    {
      nixosConfigurations.nirvana =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs // { isNotWSL = true; };
          modules = [
            {
              # Disable the default systemd-boot implem
              disabledModules = [ "system/boot/loader/systemd-boot/systemd-boot.nix" ];
            }
            # Enable our own systemd-boot implementation
            ./systemd-boot-override/systemd-boot.nix
            ./hardware-configuration.nix
            home-manager.nixosModules.home-manager
            lanzaboote.nixosModules.lanzaboote
            hyprland.nixosModules.default
            ./configuration.nix
            ./cola.nix
          ];
        };
    };
}
