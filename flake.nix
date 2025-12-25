{
  description = "actus-core flake";

  inputs = {
    actus-tests = {
      url = "github:actusfrf/actus-tests";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    haskell-nix = {
      url = "github:input-output-hk/haskell.nix?ref=2025.12.21";
    };
    nixpkgs.follows = "haskell-nix/nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      inherit (pkgs) lib;

      repoRoot = ./.;

      pkgs =
        import inputs.nixpkgs {
          inherit system;
          config = inputs.haskell-nix.config;
          overlays = [
            inputs.haskell-nix.overlay
          ];
        };

      # overlays = [ haskell-nix.overlay
      #   (final: prev: {
      #    actusCore =
      #      final.haskell-nix.project' {
      #        src = ./.;
      #        compiler-nix-name = "ghc984";
      #        shell.tools = {
      #          cabal = {};
      #        };
      #        shell.buildInputs = with pkgs; [
      #          nixpkgs-fmt
      #        ];
      #        shell.shellHook = ''
      #          export ACTUS_TEST_DATA_DIR=${actus-tests}/tests/
      #          '';
      #      };
      #  })
      #];
      #pkgs = import nixpkgs { inherit system overlays; inherit (haskell-nix) config; };

      project = pkgs.haskell-nix.cabalProject' (
        { config, pkgs, ... }:
        {
          name = "actus-core";
          compiler-nix-name = lib.mkDefault "ghc984";
          src = lib.cleanSource ./.;
          modules = [{
            packages = { };
          }];
        }
      );

      packages = {
        default = project.packages."actus-core:lib:actus-core";
      };

      devShells = {
        default = import ./nix/shell.nix {
          inherit inputs pkgs lib project system repoRoot;
        };
      };
    in
    {
      inherit packages;
      inherit devShells;
    }
  );
}

# outputs = { self, nixpkgs, flake-utils, haskell-nix, actus-tests }:
#   flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
#   let
#     overlays = [ haskell-nix.overlay
#       (final: prev: {
#         actusCore =
#           final.haskell-nix.project' {
#             src = ./.;
#             compiler-nix-name = "ghc984";
#             shell.tools = {
#               cabal = {};
#             };
#             shell.buildInputs = with pkgs; [
#               nixpkgs-fmt
#             ];
#             shell.shellHook = ''
#               export ACTUS_TEST_DATA_DIR=${actus-tests}/tests/
#               '';
#           };
#       })
#     ];
#     pkgs = import nixpkgs { inherit system overlays; inherit (haskell-nix) config; };
#     flake = pkgs.actusCore.flake {
#     };
#   in flake // {
#     packages.default = flake.packages."actus-core:lib:actus-core";
#   });
