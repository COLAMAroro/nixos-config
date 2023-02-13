{
  description = "NixOS Configuration for workstation";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote"; # Lanzaboote is currently unused, as support for dual-boot is *janky*
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs =
    { self
    , nixpkgs
    , nixos-hardware
    , home-manager
    , lanzaboote
    , hyprland
    , ...
    }@inputs:
    {
      nixosConfigurations.nirvana =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              # Disable the default systemd-boot implem
              disabledModules = [ "system/boot/loader/systemd-boot/systemd-boot.nix" ];
            }
            # Enable our own systemd-boot implementation
            ./extensions/systemd-boot-override/systemd-boot.nix
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            nixos-hardware.nixosModules.common-pc-amd
            nixos-hardware.nixosModules.common-pc-nvidia-nonprime
            nixos-hardware.nixosModules.common-pc-ssd
            ./devices/shared.nix
            ./devices/nirvana/hardware-configuration.nix
            ./devices/nirvana/configuration.nix
            ./user/cola.nix
          ];
          specialArgs = inputs // {
            isGraphical = true;
            isNotWSL = true;
            hasGnome = true;
            hasHyprland = false;
          };
        };
      nixosConfigurations."hades" =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            hyprland.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            nixos-hardware.nixosModules.lenovo-thinkpad-t470s
            ./devices/shared.nix
            ./devices/hades/zfs.nix
            ./devices/hades/hardware-configuration.nix
            ./devices/hades/configuration.nix
            ./user/cola.nix
          ];
          specialArgs = inputs // {
            isGraphical = true;
            isNotWSL = true;
            hasGnome = true;
            hasHyprland = true;
          };
        };
    };
}
