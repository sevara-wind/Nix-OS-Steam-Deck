{ config, pkgs, lib, inputs, ... }:

let
  userOpts = import ./options.nix;
in
{
  system.stateVersion = "24.11"; 
  networking.hostName = "steamdeck";
  networking.networkmanager.enable = true;
  
  time.timeZone = userOpts.timeZone; 

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];
  i18n.defaultLocale = lib.strings.removeSuffix "/UTF-8" userOpts.defaultLocale;

  boot.loader = {
    systemd-boot.enable = false;
    grub.enable = false;
    
    limine = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      style.wallpapers = [ ./wallpaper.png ];
      extraConfig = ''
        interface_rotation: 90
        graphics: yes
        timeout: 5
        wallpaper_style: stretch
        background_color: #00000000
        text_color: #ffffffff
        text_highlight_color: #ff00ffff
      '';
    };
    efi.canTouchEfiVariables = true;
  };

  boot.kernelParams = [ 
    "video=DSI-1:panel_orientation=right_side_up" 
    "fbcon=rotate:1" 
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  jovian = {
    devices.steamdeck.enable = true;
    steamos.useSteamOSConfig = true; 
    hardware.has.amd.gpu = true;
    decky-loader.enable = true;      
    steam = {
      enable = true;
      autoStart = true;         
      user = userOpts.username;
      desktopSession = "gnome"; 
    };
  };

  hardware.enableRedistributableFirmware = true;
  security.rtkit.enable = true;

  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true; 
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  services.displayManager.gdm.enable = lib.mkForce false; 

  services.displayManager.autoLogin = {
    enable = true;
    user = userOpts.username;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  users.mutableUsers = true;

  users.users.${userOpts.username} = {
    isNormalUser = true;
    description = userOpts.username;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
  };

  users.users.root = {};

  services.openssh = {
    enable = true;
    openFirewall = true; 
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "prohibit-password"; 
    };
  };

  programs.throne = {
     enable = true;
     tunMode.enable = true;
  };

  # Enable graphical installer for Live-ISO deployment natively
  installer.calamares.enable = true;

  # All system packages merged into a single clean declarative block
  environment.systemPackages = with pkgs; [
    nano git htop firefox curl procps gawk gnugrep
    coreutils findutils util-linux go psmisc fastfetch
    appimage-run steam-run bashInteractive shared-mime-info
    gparted # Added directly here to prevent attribute definition conflicts
  ];
}
