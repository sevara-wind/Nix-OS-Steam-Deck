{ config, pkgs, lib, ... }:

{
  system.stateVersion = "24.11"; 
  networking.hostName = "steamdeck-nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Moscow"; 

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
      user = "sevara";           
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

  users.users.sevara = {
    isNormalUser = true;
    description = "sevara";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" ];
    hashedPassword = "$6$sF3Izx227qeOCqjC$WMeWos2TsVsV8ELD7r6MBExaGvrWIVapON2x2GWii6KyXE7yqAPnoBfr08gZ5FMiO6M3MUt1t5453af16ZKsh/"; 
  };
  users.users.root.hashedPassword = "$6$sF3Izx227qeOCqjC$WMeWos2TsVsV8ELD7r6MBExaGvrWIVapON2x2GWii6KyXE7yqAPnoBfr08gZ5FMiO6M3MUt1t5453af16ZKsh/";

  services.openssh = {
    enable = true;
    openFirewall = true; 
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes"; 
    };
  };

  programs.throne = {
     enable = true;
     tunMode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nano
    git
    htop
    firefox
    curl
    procps
    gawk
    gnugrep
    coreutils
    findutils
    util-linux
    go
    psmisc
  ];
}
