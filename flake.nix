{
  description = "Steam Deck Jovian NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    nix-crab.url = "github:ItszFinn/nix-crab";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, jovian, nix-crab, home-manager, ... }@inputs: {
    nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; 
      modules = [
        jovian.nixosModules.default
        nix-crab.nixosModules.default
        home-manager.nixosModules.home-manager
        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };
  };
}
