{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
  ];

  # --- Nix Settings ---
  # This allows you to use the 'nix' command without needing flakes
  nix.settings.experimental-features = [ "nix-command" ];

  # --- Bootloader ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;

  security.pam.services.hyprlock = {};

  # --- Networking ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # --- Localization ---
  time.timeZone = "Africa/Casablanca";
  i18n.defaultLocale = "en_GB.UTF-8";
  
  # Simplified locale settings
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
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Keyboard Layout
  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };
  console.keyMap = "fr";

  # --- Sound & Services ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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
    postman 
    docker-compose
    nodejs_20 php php82Extensions.curl php82Extensions.mysqli mysql80

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
    
    # Hyprland Essentials
    waybar 
    hyprlock  
    dunst 
    rofi
    awww
    elephant
    walker
    pywal 
    wlogout 
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
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "zsh-autosuggestions" "zsh-syntax-highlighting" ];
      theme = "powerlevel10k/powerlevel10k";
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

  # Changed from 25.11 to 24.11 (the current stable release)
  system.stateVersion = "24.11"; 
}
