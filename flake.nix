{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };
    in
    {
      devShells.${system} = {
        fhs =
          let
            fhs = (pkgs.buildFHSEnv.override { stdenv = pkgs.clangStdenv; }) {
              name = "fhs-shell";
              targetPkgs = pkgs: [ pkgs.zlib ];
            };
          in
          fhs.env;

        default = pkgs.mkShell {
          packages =
            let
              python = pkgs.python3.withPackages (
                ps: with ps; [
                  jax-cuda12-plugin
                  jaxlib

                  ml-dtypes
                  numpy
                  opt-einsum
                  scipy

                  pytest

                  debugpy
                ]
              );
            in
            [ python ];

          shellHook = ''
            export PYTHONPATH=build/:$PYTHONPATH
          '';
        };
      };
    };
}
