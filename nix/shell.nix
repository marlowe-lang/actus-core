{ project, repoRoot, inputs, pkgs, lib, system, ghcVersion ? "ghc984" }:
let
  name = "actus-core";

  # This could be probably moved to `shellFor { tools = { cabal = "latest",.. }}` but
  # then the hooks setup should be modified as well. Not sure how to do that cleanly.
  tools = {
    cabal = (project.tool "cabal" "latest");
    cabal-fmt = (project.tool "cabal-fmt" "latest");
    haskell-language-server = (project.tool "haskell-language-server" "latest");
    stylish-haskell = (project.tool "stylish-haskell" "latest");
    fourmolu = (project.tool "fourmolu" "latest");
    hlint = (project.tool "hlint" "latest");
  };

  preCommitCheck = inputs.pre-commit-hooks.lib.${pkgs.system}.run {
    src = lib.cleanSources ../.;

    hooks = {
      cabal-fmt = {
        enable = true;
        package = tools.cabal-fmt;
      };
      fourmolu = {
        enable = true;
        package = tools.fourmolu;
      };
      hlint = {
        enable = true;
        package = tools.hlint;
        args = [ "--hint" ".hlint.yaml" ];
      };
      nixpkgs-fmt = {
        enable = true;
        package = pkgs.nixpkgs-fmt;
      };
      shellcheck = {
        enable = true;
        package = pkgs.shellcheck;
      };
      stylish-haskell = {
        enable = false;
        package = tools.stylish-haskell;
        args = [ "--config" ".stylish-haskell.yaml" ];
      };
    };
  };

  shell = project.shellFor {
    buildInputs = [
      tools.haskell-language-server
      tools.haskell-language-server.package.components.exes.haskell-language-server-wrapper
      tools.stylish-haskell
      tools.fourmolu
      tools.cabal
      tools.hlint
      tools.cabal-fmt
    ];


    shellHook = ''
      ${preCommitCheck.shellHook}
    '';

    withHoogle = false;
  };
in
shell


