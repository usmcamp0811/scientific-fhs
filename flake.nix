{
  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux"; # Default system
      darwinSystem = "x86_64-darwin";
      linuxSystem = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

      darwinPkgs = import nixpkgs {
        system = darwinSystem;
      };

      linuxPkgs = import nixpkgs {
        system = linuxSystem;
      };
    in
    {
      nixosModules.default = import ./module.nix;

      packages.x86_64-linux.scientific-fhs = linuxPkgs.callPackage ./fhs.nix {
        enableNVIDIA = true;
        enableGraphical = true;
        juliaVersion = "1.10.0";
      };

      packages.x86_64-darwin.scientific-fhs = darwinPkgs.callPackage ./fhs.nix {
        enableNVIDIA = false; # Assuming NVIDIA support is irrelevant for Darwin, adjust if needed
        enableGraphical = true;
        juliaVersion = "1.10.0";
      };
    };
}
