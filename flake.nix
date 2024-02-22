{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            # Any other global configurations you'd like to include.
          };
        };
      in
      {
        packages = {
          scientific-fhs = pkgs.callPackage ./fhs.nix {
            pkgs = pkgs;
            # enableNVIDIA = true;
            # enableGraphical = true;
            # juliaVersion = "1.10.0";
          };
        };

        # Optional: Define default packages for convenience.
        defaultPackage = self.packages.${system}.scientific-fhs;
      }
    );
}
