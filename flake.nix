{
  description = "Steam Deck Jovian NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    
    # Official nixos-generators repository tracked for build targets
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, jovian, nixos-generators, ... }@inputs: {
    # Standard profile for local physical hardware deployment
    nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; 
      modules = [
        jovian.nixosModules.default
        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };

    # Natively handled ISO installer generation target using updated attribute map
    packages.x86_64-linux.iso = nixos-generators.nixosGenerate {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      format = "install-iso";
      specialArgs = { inherit inputs; };
      modules = [
        jovian.nixosModules.default
        ./configuration.nix
        
        # Inject installer properties safely inside the proper build container
        ({ pkgs, lib, ... }: {
          installer.calamares.enable = true;
          services.displayManager.autoLogin.user = lib.mkForce "nixos";
          
          # Safely suppress physical storage evaluations during virtual building phases
          fileSystems = lib.mkForce {};
          boot.loader.grub.enable = lib.mkForce false;
        })
      ];
    };
  };
}
