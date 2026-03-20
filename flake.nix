{
  description = "Nix-direnv templates";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "x86_64-linux"

        "x86_64-darwin"
        "aarch64-darwin"
      ];

      flake.templates = {
        default = {
          path = ./nix-flakes;
          description = "Nix-flakes template";
        };
        rust = {
          path = ./rust;
          description = "Rust template";
        };
        python3 = {
          path = ./python3;
          description = "Python3";
        };
      };

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt;

          devShells.default =
            let
              forEachDir = exec: ''
                for dir in */; do
                  (
                    cd "''${dir}"

                    ${exec}
                  )
                done
              '';

              script =
                name: runtimeInputs: text:
                pkgs.writeShellApplication {
                  inherit name runtimeInputs text;
                  bashOptions = [
                    "errexit"
                    "pipefail"
                  ];
                };
            in
            pkgs.mkShellNoCC {
              packages = with pkgs; [
                (script "check" [ nixfmt ] (forEachDir ''
                  echo "checking ''${dir}"
                  nix flake check --all-systems --no-build
                ''))
                (script "format" [ nixfmt ] ''
                  git ls-files '*.nix' | xargs nix fmt
                '')
                (script "check-formatting" [ nixfmt ] ''
                  git ls-files '*.nix' | xargs nixfmt --check
                '')
              ];
            };
        };
    };
}
