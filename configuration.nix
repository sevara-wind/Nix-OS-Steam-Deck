{ config, pkgs, ... }:

{
  # Nix core experimental features enabled
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree software (Non-free software support)
  nixpkgs.config.allowUnfree = true;

  # Standard bootloader with rotated text console support
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel parameters to fix terminal and boot screen rotation on Steam Deck display
  boot.kernelParams = [ 
    "video=DSI-1:panel_orientation=right_side_up" 
    "fbcon=rotate:1" 
  ];

  # Network configuration
  networking.hostName = "jovian-deck";
  networking.networkmanager.enable = true;

  # OpenSSH server configuration completely enabled
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";        # Allows root login over SSH
      PasswordAuthentication = true; # Allows password auth over SSH
    };
  };

  # Automatic optimization and data cleanup
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Enable Flatpak service
  services.flatpak.enable = true;

  # Desktop Environment configuration - GNOME
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # System User configuration for sevara
  users.users.sevara = {
    isNormalUser = true;
    description = "sevara";
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "baccano"; 
  };

  # Also set root password fallback
  users.users.root.initialPassword = "baccano";

  # Pre-installed system applications
  environment.systemPackages = with pkgs; [
    firefox
    git
    curl
    wget
  ];

  system.stateVersion = "24.11"; 
}
