{
  description = "Steam Deck Jovian NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
  };

  outputs = { self, nixpkgs, jovian, ... }@inputs: {
    # Standard profile for installation on the physical Steam Deck hardware
    nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Explicitly set architecture to bypass missing configuration warnings
      specialArgs = { inherit inputs; }; 
      modules = [
        jovian.nixosModules.default
        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };

    # Isolated profile for generating the live bootable ISO via GitHub Actions
    nixosConfigurations.isoProfile = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Explicitly set architecture to bypass missing configuration warnings
      specialArgs = { inherit inputs; };
      modules = [
        # Load the native graphic installer module for GNOME/Calamares deployment
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
        jovian.nixosModules.default
        ./configuration.nix
        
        # Override specific configuration options for the live environment evaluation
        ({ pkgs, lib, ... }: {
          installer.calamares.enable = true;
          services.displayManager.autoLogin.user = lib.mkForce "nixos";
          
          # Force set host platform to clear architecture verification traps
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          
          # Force ignore storage device configurations during virtual evaluation
          fileSystems = lib.mkForce {};
          boot.loader.grub.enable = lib.mkForce false;
        })
      ];
    };
  };
}
