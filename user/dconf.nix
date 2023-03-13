{
  # Enable extensions (installed via gnome-extensions)
  "org/gnome/shell".enabled-extensions = [
    "dash-to-panel@jderose9.github.com"
    "nightthemeswitcher-gnome-shell-extension@rmnvgr.gitlab.com"
    "appindicatorsupport@rgcjonas.gmail.com"
    "nightthemeswitcher@romainvigier.fr"
  ];
  # Set workspace settings
  "org/gnome/desktop/wm/preferences".num-workspaces = 1;
  "org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";
  # Set alt-tab as a *real* alt-tab
  "org/gnome/desktop/wm/keybindings" = {
    switch-applications = "@as []";
    switch-applications-backward = "@as []";
    switch-windows = [ "<Alt>Tab" ];
    switch-windows-backward = [ "<Shift><Alt>Tab" ];
  };
  # Ctrl+Shift+Escape to open task manager
  "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
    binding = "<Shift><Control>Escape";
    command = "gnome-system-monitor";
    name = "Task Manager";
  };
  # Enable mutter
  "org/gnome/mutter" = {
    experimental-features = [ "scale-monitor-framebuffer" ];
    dynamic-workspaces = false;
  };
  # Enable location services
  "org/gnome/system/location".enabled = true;
  # Enable night theme switcher
  "org/gnome/shell/extensions/nightthemeswitcher/cursor-variants" = {
    enabled = true;
    night = "Adwaita-dark";
  };
  "org/gnome/shell/extensions/nightthemeswitcher/icon-variants" = {
    enabled = true;
    night = "Adwaita-dark";
  };
  "org/gnome/shell/extensions/nightthemeswitcher/gtk-variants" = {
    enabled = true;
    night = "Adwaita-dark";
  };
  "org/gnome/shell/extensions/nightthemeswitcher/shell-variants".enabled = true;
  "org/gnome/shell/extensions/nightthemeswitcher/time".manual-schedule = false;
  "org/gnome/shell/extensions/nightthemeswitcher/time".nightthemeswitcher-ondemand-keybinding = [ "" ];
}
