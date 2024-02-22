{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        isDarwin = system == "x86_64-darwin" || system == "aarch64-darwin";
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
            inherit (pkgs) stdenv mkShell;
            enableNVIDIA = !isDarwin;
            enableGraphical = true;
            enableQuarto = !isDarwin;
            juliaVersion = "1.10.0";
          };
        };

        # Optional: Define default packages for convenience.
        defaultPackage = self.packages.${system}.scientific-fhs;
      }
    );
}
