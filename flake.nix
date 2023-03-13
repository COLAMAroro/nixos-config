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
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , nixos-hardware
    , home-manager
    , lanzaboote
    , hyprland
    , disko
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
            hyprland.nixosModules.default # Hyprland is unused, but we need to import to suppress an error about hyprland being undefined
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
            nixos-hardware.nixosModules.common-pc
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
      nixosConfigurations."agni" =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            hyprland.nixosModules.default
            home-manager.nixosModules.home-manager
            nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd # Technically a L15, but the L14 is the closest match. And I like danger.
            ./devices/shared.nix
            ./devices/agni/hardware-configuration.nix
            ./devices/agni/configuration.nix
            ./user/cola.nix
          ];
          specialArgs = inputs // {
            isGraphical = true;
            isNotWSL = true;
            hasGnome = true;
            hasHyprland = true;
          };
        };
      nixosConfigurations."thoth" =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            hyprland.nixosModules.default
            home-manager.nixosModules.home-manager
            ./devices/shared.nix
            ./devices/thoth/hardware-configuration.nix
            ./devices/thoth/configuration.nix
            ./user/cola.nix
          ];
          specialArgs = inputs // {
            isGraphical = false;
            isNotWSL = true;
            hasGnome = false;
            hasHyprland = false;
          };
        };
      nixosConfigurations."apollo" =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            hyprland.nixosModules.default
            home-manager.nixosModules.home-manager
            ./devices/shared.nix
            ./devices/apollo/hardware-configuration.nix
            ./devices/apollo/configuration.nix
            ./user/cola.nix
          ];
          specialArgs = inputs // {
            isGraphical = false;
            isNotWSL = true;
            hasGnome = false;
            hasHyprland = false;
          };
        };
      nixosConfigurations."anunnaki" =
        nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            hyprland.nixosModules.default
            home-manager.nixosModules.home-manager
            ./devices/shared.nix
            ./devices/anunnaki/hardware-configuration.nix
            ./devices/anunnaki/configuration.nix
            ./user/cola.nix
            ({ modulesPath, ... }: {
              imports = [ disko.nixosModules.disko ];
              disko.devices = import ./devices/anunnaki/disk.nix { lib = nixpkgs.lib; };
            })
          ];
          specialArgs = inputs // {
            isGraphical = false;
            isNotWSL = true;
            hasGnome = false;
            hasHyprland = false;
          };
        };
    };
}
