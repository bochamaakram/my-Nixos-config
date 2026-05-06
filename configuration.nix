{ config, pkgs, lib, ... }:


{
  imports = [ 
    ./hardware-configuration.nix    
 ];

  # --- Nix Settings ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Bootloader ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;

  security.pam.services.hyprlock = {};

  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
    settings = {
      blur = {
        method = "dual_kawase";
        strength = 7;
      };
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

# Add this to your environment.variables or environment.sessionVariables
  environment.sessionVariables = {
    QML2_IMPORT_PATH = [
      "${pkgs.qt6.qt5compat}/lib/qt-6/qml"
      "${pkgs.qt6.qtwayland}/lib/qt-6/qml"
    ];
  };

  # Optional: Enable autodiscovery of network printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.printing.drivers = [ pkgs.hplip pkgs.cnijfilter2 ];

  # --- Networking ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true; 
  networking.wireless.iwd.enable = false;

  # --- Localization ---
  time.timeZone = "Africa/Casablanca";
  i18n.defaultLocale = "en_GB.UTF-8";
  
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # --- Power Management (ThinkPad Specific) ---
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;  
    };
  };

  # --- Desktop Environment ---
  services.xserver = {
    enable = true;
    xkb = {
      layout = "fr";
      variant = "azerty";
    };
  };
  
  services.displayManager.gdm.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "akram";
  services.desktopManager.gnome.enable = true;

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  console.keyMap = "fr";

  # --- Audio (PipeWire) ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # --- XDG Portals ---
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # --- Bluetooth Support ---
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # --- Virtualization ---
  services.flatpak.enable = true;
  virtualisation.docker.enable = true;

  # --- User Setup ---
  users.users.akram = {
    isNormalUser = true;
    description = "akram";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # --- System-wide Packages ---
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    quickshell
    playerctl
    qt6.qtwayland
    qt6.qt5compat
    libpulseaudio
    brightnessctl
    networkmanagerapplet
    gnome-themes-extra
    # Browsers & Dev
    brave  
    vscode
    antigravity 
    git
    jq
    gh 
    uv
    postman 
    docker-compose
    nodejs_20
    php php82Extensions.curl
    php82Extensions.mysqli

    # Terminal & Tools
    kitty 
    terminator 
    neovim 
    btop
    opencode 
    fastfetch 
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    meslo-lgs-nf    
    cmatrix
    cava
    vesktop
    asciiquarium
    xdotool
    brightnessctl
    wireplumber
    
    # Hyprland Essentials
    waybar 
    hyprlock
    hypridle  
    dunst
    cliphist
    wl-clipboard 
    rofi
    awww
    qt6.qtwayland
    obs-studio
    elephant
    walker
    qt6.qt5compat
    pywal
    bluetui  
    waypaper
    quickshell
    polkit_gnome 
    wl-clipboard 
    grim 
    slurp
    
    # Theme Helpers
    catppuccin-gtk 
    catppuccin-papirus-folders 
    catppuccin-cursors.mochaMauve
    blueman networkmanagerapplet  
  ];
# --- Programs Configuration ---
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      if [ -f ~/.cache/wal/sequences ]; then
          (cat ~/.cache/wal/sequences &)
      fi
    '';
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };

  # --- Fonts ---
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

security.polkit.enable = true;

  # --- Cleanup & State ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "24.11"; 
}
