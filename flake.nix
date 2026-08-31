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

    # Bulletproof ISO Profile with explicitly declared Calamares module imports
    nixosConfigurations.isoProfile = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Load the base graphical installation setup components
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
        "${nixpkgs}/nixos/modules/profiles/graphical.nix"
        
        # FORCE IMPORT: Directly pull the calamares module declaration file to bypass profile evaluation traps
        "${nixpkgs}/nixos/modules/installer/tools/tools.nix"
        
        jovian.nixosModules.default
        ./configuration.nix
        
        # Apply sandboxed tweaks tailored strictly for the Live-USB runtime container
        ({ pkgs, lib, ... }: {
          # Now this option is explicitly defined and guaranteed to exist
          installer.calamares.enable = true;
          
          # Configure desktop manager properties for the Live environment
          services.xserver.desktopManager.gnome.enable = true;
          services.displayManager.autoLogin.user = lib.mkForce "nixos";
          
          # Force drop hardware storage configurations during the virtual build phase
          fileSystems = lib.mkForce {};
          boot.loader.grub.enable = lib.mkForce false;
          boot.loader.limine.enable = lib.mkForce false;
        })
      ];
    };
  };
}
