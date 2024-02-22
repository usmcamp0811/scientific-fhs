{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = { self, poetry2nix, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # NOTE: Darwin is still busted
        isDarwin = system == "x86_64-darwin" || system == "aarch64-darwin";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            poetry2nix.overlays.default
          ];
          config = {
            allowUnfree = true;
            allowUnsupportedSystem = true;
            # Any other global configurations you'd like to include.
          };
        };

        python-env = let
        # This is required if you get odd errors
        # read the https://github.com/nix-community/poetry2nix/blob/master/docs/edgecases.md
        pypkgs-build-requirements = {
          pyjulia = [ "setuptools"];
          julia = [ "setuptools" ];
          juliapkg = [ "setuptools" ];
          urllib3 = [ "hatchling" ];
          juliacall = [ "setuptools" ];
          pandas = [ "versioneer" ];
          sphinxcontrib-jquery = [ "sphinx" "setuptools" ];
          gunicorn = ["setuptools-scm"];
        };

        p2n-overrides = pkgs.poetry2nix.defaultPoetryOverrides.extend (self: super:
          builtins.mapAttrs (package: build-requirements:
            (builtins.getAttr package super).overridePythonAttrs (old: {
              buildInputs = (old.buildInputs or [ ]) ++ (builtins.map (pkg: if builtins.isString pkg then builtins.getAttr pkg super else pkg) build-requirements);

            })
          ) pypkgs-build-requirements
        );
        in
        pkgs.poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          python = pkgs.python311;
          overrides = p2n-overrides;
          preferWheels = true;
        };
      in
      {
        packages = {
          scientific-fhs = pkgs.callPackage ./fhs.nix {
            inherit (pkgs) stdenv mkShell;
            enableNVIDIA = !isDarwin;
            enableGraphical = !isDarwin;
            enableQuarto = !isDarwin;
            juliaVersion = "1.10.0";
            poetryEnv = python-env;
          };
        };

        # Optional: Define default packages for convenience.
        defaultPackage = self.packages.${system}.scientific-fhs;
      }
    );
}
