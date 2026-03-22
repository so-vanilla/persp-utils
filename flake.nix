{
  description = "Utility packages for perspective.el";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.persp-utils = pkgs.emacsPackages.trivialBuild {
          pname = "persp-utils";
          version = "0.1.0";
          src = ./.;
          packageRequires = [ pkgs.emacsPackages.perspective ];
        };
      }
    );
}
