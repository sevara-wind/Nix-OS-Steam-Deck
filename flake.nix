{
  description = "NixOS Custom Steam Deck GNOME ISO";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      steamdeck = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration.nix ];
      };

      my-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./configuration.nix
          ({ pkgs, ... }: {
            fileSystems = pkgs.lib.mkForce {};
            boot.loader.grub.enable = pkgs.lib.mkForce false;
            boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;
            services.displayManager.autoLogin.enable = pkgs.lib.mkForce true;
            services.displayManager.autoLogin.user = pkgs.lib.mkForce "nixos";
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          })
        ];
      };
    };
  };
}
