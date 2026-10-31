{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      nix-index-database,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib =
        let
          base = nixpkgs.lib // home-manager.lib;
        in
        base
        // {
          toSystemdDevice =
            device:
            base.concatStringsSep "-" (
              base.tail (map (base.replaceString "-" "\\x2d") (base.splitString "/" device))
            )
            + ".device";
        };
      systems = [ "x86_64-linux" ];
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      mkHost =
        name: host:
        lib.nixosSystem (
          lib.optionalAttrs (host ? system) { inherit (host) system; }
          // {
            modules = [
              ./hosts/${name}
              {
                networking.hostName = name;
                home-manager.users.cino = import ./home/cino/${name}.nix;
              }
            ]
            ++ lib.optional (host ? disk) { _module.args.disk = host.disk; };
            specialArgs = { inherit inputs outputs; };
          }
        );
    in
    {
      inherit lib;
      homeModules = import ./modules/home-manager;

      overlays = import ./overlays { inherit inputs outputs; };

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixfmt-tree);
      checks = forEachSystem (
        pkgs:
        import ./checks {
          inherit pkgs lib;
          inherit (self) nixosConfigurations;
        }
      );

      # A host NAME is hosts/NAME paired with home/cino/NAME.nix. Extra
      # attrs: `system`, and `disk` for hosts partitioned by disko.
      nixosConfigurations = lib.mapAttrs mkHost {
        # Asus Chromebook
        c302 = {
          disk = "/dev/mmcblk0";
        };

        # WSL
        wsl = {
          system = "x86_64-linux";
        };

        # Lenovo Yoga
        yoga530 = {
          system = "x86_64-linux";
          disk = "/dev/disk/by-id/nvme-SAMSUNG_MZVLW128HEGR-000L2_S35FNX0K439214";
        };
      };

      # homeConfigurations = {
      #   "cino@c302" = lib.homeManagerConfiguration {
      #     modules = [ ./home/cino/c302.nix ];
      #     pkgs = pkgsFor.x86_64-linux;
      #     extraSpecialArgs = { inherit inputs outputs; };
      #   };
      # };
    };
}
