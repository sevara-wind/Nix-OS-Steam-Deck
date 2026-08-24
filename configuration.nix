{ config, pkgs, lib, ... }:

{
  system.stateVersion = "24.11"; 
  networking.hostName = "steamdeck-nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Moscow"; 

  # Принудительный сброс видеорежима UEFI для выравнивания меню по горизонтали
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "0";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  # Разворот на 90 градусов по часовой стрелке при старте ядра ОС
  boot.kernelParams = [ 
    "video=DSI-1:panel_orientation=right_side_up" 
    "fbcon=rotate:1" 
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Настройки графики, звука и кнопок громкости
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
    initialPassword = "baccano"; 
  };
  users.users.root.initialPassword = "baccano";

  services.openssh = {
    enable = true;
    openFirewall = true; 
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes"; 
    };
  };

  # Включение Throne с системной TUN-оберткой
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
