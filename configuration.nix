{ config, pkgs, lib, inputs, ... }:

{
  system.stateVersion = "24.11"; 
  networking.hostName = "steamdeck";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Moscow"; 

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

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

  # nix-crab: declarative SLSsteam + CloudRedirect (h3adcr-b equivalent)
  # LuaTools stack: slssteam-moon injects the SLSsteam fork with a native Lua
  # manifest importer; cloudredirect.moon makes the hook aware of stplug-in games.
  programs.nix-crab = {
    slssteam.enable = true;
    slssteam-moon.enable = true;
    cloudredirect.enable = true;
    cloudredirect.moon.enable = true;
  };

  hardware.enableRedistributableFirmware = true;
  security.rtkit.enable = true;

  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true; 
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  services.displayManager.gdm.enable = lib.mkForce false; 

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

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
    fastfetch
    appimage-run
    steam-run
    bashInteractive
    shared-mime-info
  ];

  # home-manager: nix-crab home modules (SLSsteam config.yaml, netsock,
  # CloudRedirect, LuaTools, SteaMidra, ACCELA). Imported from our own
  # homeModules output, which pins the steamidra input to a stable static JSON
  # (see flake.nix) instead of the volatile GitHub-API URL.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."sevara" = {
      home.stateVersion = "24.11";
      imports = [
        inputs.self.homeModules.steamidra
      ];
      # LuaTools frontend (Lumen + plugin), cloud hook to match the NixOS side,
      # the SteaMidra (SFF) desktop app and ACCELA.
      programs.nix-crab = {
        luatools.enable = true;
        cloudredirect.moon.enable = true;
        steamidra.enable = true;
        accela.enable = true;
      };
    };
  };
}
