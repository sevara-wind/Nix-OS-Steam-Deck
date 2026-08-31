{
  description = "Steam Deck Jovian NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
  };

  outputs = { self, nixpkgs, jovian, ... }@inputs: {
    # Standard profile for local hardware installation
    nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; 
      modules = [
        jovian.nixosModules.default
        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };

    # Pure, native ISO Profile that pulls standard graphical CD modules safely
    nixosConfigurations.isoProfile = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Crucial upstream module that opens up installer.calamares settings cleanly
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
        jovian.nixosModules.default
        ./configuration.nix
        
        # Isolated sandbox configurations to bypass deployment device errors during build phase
        ({ pkgs, lib, ... }: {
          installer.calamares.enable = true;
          services.displayManager.autoLogin.user = lib.mkForce "nixos";
          
          # Overwrite physical configurations to evaluate safely inside the virtual builder
          fileSystems = lib.mkForce {};
          boot.loader.grub.enable = lib.mkForce false;
          boot.loader.limine.enable = lib.mkForce false;
        })
      ];
    };
  };
}
