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

  # Jovian NixOS optimization for Steam Deck
  jovian = {
    devices.steamdeck.enable = true;
    
    # Replicates original SteamOS system/audio configurations perfectly
    steamos.useSteamOSConfig = true;
    
    steam = {
      enable = true;
      autoStart = true;          # Force boots directly into Gamescope Gaming Mode session
      user = "sevara";           # Set main Gaming Mode user to sevara
      desktopSession = "gnome";  # Desktop mode target when you click "Switch to Desktop"
    };
    # Enable Decky Loader support declaratively
    decky-loader.enable = true;
  };

  # Low-latency audio support required by Jovian SteamOS subsystem
  security.rtkit.enable = true;

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

  # System User configuration for sevara
  users.users.sevara = {
    isNormalUser = true;
    description = "sevara";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
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

  # Throne VPN configuration with active tunMode tunneling
  programs.throne = {
     enable = true;
     tunMode = {
       enable = true;
       setuid = true; 
     };
  };

  system.stateVersion = "24.11"; 
}
