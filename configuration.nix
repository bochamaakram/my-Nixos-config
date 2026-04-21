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

# --- Networking (Standard & Stable) ---
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

  # --- Desktop Environment & Hyprland ---
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

  # --- XDG Portals (Crucial for OBS Screen Sharing) ---
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

# --- Bluetooth Support ---
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # --- Services ---
  services.printing.enable = true;
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
    # Browsers & Dev
    brave  
    vscode 
    git
    gh
    antigravity 
    uv
    claude-code
    postman 
    docker-compose
    nodejs_20
    php php82Extensions.curl
    php82Extensions.mysqli
    mysql80

    # Terminal & Tools
    kitty 
    terminator 
    neovim 
    btop 
    fastfetch 
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    meslo-lgs-nf    
    cmatrix
    asciiquarium
    xdotool
    brightnessctl
    wireplumber
    
    # Hyprland Essentials
    waybar 
    hyprlock
    hypridle  
    dunst 
    rofi
    awww
    obs-studio
    elephant
    walker
    pywal
    impala
    bluetui  
    waypaper 
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

  # --- Cleanup & State ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "24.11"; 
}
