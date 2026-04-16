{
  description = "A basic flake for web development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        cssmodules-language-server = pkgs.buildNpmPackage (finalAttrs: {
          pname = "cssmodules-language-server";
          version = "1.5.2";

          src = pkgs.fetchFromGitHub {
            owner = "antonk52";
            repo = "cssmodules-language-server";
            rev = "v${finalAttrs.version}";
            hash = "sha256-9RZNXdmBP4OK7k/0LuuvqxYGG2fESYTCFNCkAWZQapk=";
          };

          npmDepsHash = "sha256-1CnCgut0Knf97+YHVJGUZqnRId/BwHw+jH1YPIrDPCA=";
        });

        css-variables-language-server = pkgs.buildNpmPackage (finalAttrs: {
          pname = "css-variables-language-server";
          version = "2.8.4";

          src = pkgs.fetchFromGitHub {
            owner = "vunguyentuan";
            repo = "vscode-css-variables";
            rev = "css-variables-language-server@${finalAttrs.version}";
            hash = "sha256-NdacBF8sUOij6k4AkMim93LrBJi8JL43q/N8GryTXHA=";
          };

          npmDepsHash = "sha256-cgX/M05UGsx87QO/Ge0VCD2hQ9MkfJarJVNCj/IcnM0=";

          nativeBuildInputs = [
            pkgs.makeWrapper
            pkgs.pkg-config
          ];

          buildInputs = [
            pkgs.libsecret
          ];

          dontNpmBuild = true;
          buildPhase = ''
            runHook preBuild

            patchShebangs .
            npm run build

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/lib/css-variables-language-server $out/bin
            cp -r . $out/lib/css-variables-language-server

            makeWrapper ${pkgs.nodejs}/bin/node $out/bin/index.js --add-flags "$out/lib/css-variables-language-server/packages/css-variables-language-server/dist/index.js"

            mv $out/bin/index.js $out/bin/css-variables-language-server

            runHook postInstall
          '';
        });
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_latest
            pnpm
            vscode-langservers-extracted
            vscode-css-languageserver
            cssmodules-language-server
            css-variables-language-server
            vscode-json-languageserver
            typescript-language-server
            eslint
          ];
        };
      }
    );
}
