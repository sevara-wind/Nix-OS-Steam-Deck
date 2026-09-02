{
  description = "Steam Deck Jovian NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    nix-crab = {
      url = "github:ItszFinn/nix-crab";
      # Override nix-crab's volatile steamidra input: it points at
      # api.github.com/.../SFF/tags whose narHash drifts hourly (GitHub embeds
      # changing download counters in that JSON), which makes every build fail
      # with "mismatch in field 'narHash'". We pin a static JSON file with the
      # same shape (newest tag first) so the narHash is stable while keeping the
      # exact same value steamidra.nix expects.
      inputs.steamidra.url = "path:./steamidra-tags.json";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, jovian, nix-crab, home-manager, ... }@inputs: {
    # nix-crab's home modules, mirroring upstream homeModules.default. We import
    # them explicitly (rather than using nix-crab.homeModules.default) so we can
    # override the steamidra input with a stable static JSON (see inputs above)
    # instead of the volatile GitHub-API URL that used to break every build.
    homeModules.steamidra = {
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
        (import "${nix-crab}/modules/steamidra.nix" {
          steamidra = nix-crab.inputs.steamidra;
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
