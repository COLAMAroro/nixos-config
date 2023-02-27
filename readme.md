# COLAMAroro's NixOS Configuration

Here is my NixOS configuration, for my different devices.

## Structure

- `flake.nix`: Entrypoint for all the devices
- `extensions/`: Extensions modules, for self-made modules
  - Now only has a custom systemd-boot module, used to override the default boot option
- `devices/`: Devices configurations
  - `shared.nix`: Shared configuration between all devices
  - `hades/`: ThinkPad t470s laptop, main NixOS device
  - `nirvana/`: Desktop PC, dual-boot with Windows 11 (Windows being the default)
  - `thoth/`: Small NUC, used as a local server (Home-Assistant, AirTable, etc.)
  - `apollo/`: VPS (Contabo), used as a music streaming server, and other web services
- `user/`: Home-Manager configuration

## Feature selection

Feature selection is done with `specialArgs` in NixOS configurations. Here are the following available toggles:

- `isGraphical`: Enable graphical environment (default: `true`)
- `isNotWSL`: Disable WSL-specific configuration (default: `true`)
- `hasGnome`: Enable Gnome desktop environment (default: `true`)
- `hasHyprland`: Enable Hyprland desktop environment (default: `false`)

## What's next ?

Ordered from most important to least important.

- Encrypt secrets with agenix or sops-nix (for user password and bitwarden tokens)
- Disko to manage drives
- Maybe add a `readme.md` for each device, to explain what's special about it ?
- A complete hyprland configuration (including waybar)
- Maybe usual "devShells" for my most used languages ?
