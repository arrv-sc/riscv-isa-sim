{
  description = "riscv-isa-sim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        { pkgs, ... }:
        rec {
          packages = rec {
            snippy = pkgs.callPackage ./snippy.nix { };
            riscv-isa-sim = pkgs.callPackage ./. { inherit snippy; };
            default = riscv-isa-sim;
          };
          checks = {
            inherit (packages) riscv-isa-sim;
          };
          devShells.default = pkgs.mkShell {
            nativeBuildInputs =
              packages.riscv-isa-sim.nativeBuildInputs
              ++ (with pkgs; [
                doxygen
                clang-tools
                lit
                filecheck
                act
                lldb
                gdb
                valgrind
                just
              ]);
            buildInputs = packages.riscv-isa-sim.buildInputs;
          };
        };
    };
}
