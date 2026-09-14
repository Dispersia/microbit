{
  description = "Zig development environment (nightly master)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";

    zls.url = "github:zigtools/zls";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      zig-overlay,
      zls,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            zig-overlay.packages.${system}.master
            zls.packages.${system}.default
            pkgs.lldb
            pkgs.usbutils
          ];
        };
      }
    );
}
