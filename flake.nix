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
    # Everything from nix-crab's homeModules.default EXCEPT steamidra.nix and
    # millennium-addons.nix. steamidra's input URL
    # (api.github.com/.../Midrags/SFF/tags) has a narHash that drifts hourly,
    # which makes every build fail with "mismatch in field 'narHash'". Excluding
    # that module means the volatile URL is never fetched during evaluation.
    homeModules.noSteamidra = {
      imports = [
        (import "${nix-crab}/modules/home.nix" {
          inherit (nix-crab.inputs)
            sls-steam
            nix-flatpak
            steamnetsock
            cloudredirect
            cloudredirect-moon
            cloudredirect-cli
            ;
        })
        (import "${nix-crab}/modules/luatools-moon.nix" {
          inherit (nix-crab.inputs) lumen luatools-moon;
        })
        (import "${nix-crab}/modules/accela.nix" {
          accela = nix-crab.inputs.accela;
        })
      ];
    };

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
