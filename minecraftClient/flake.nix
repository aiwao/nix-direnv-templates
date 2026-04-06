{
  description = "A Minecraft-client flake with using jdk21+gradle";
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
      in
      {
        devShells.default = pkgs.mkShell {
          packages =
            with pkgs;
            [
              gcc

              jdk21
              jdt-language-server
              gradle

              ncurses
              patchelf
              zlib
              pulseaudio
              openal
              pkg-config
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
              pkgs.udev
              pkgs.alsa-oss
            ];

          JAVA_HOME = pkgs.jdk21;

          shellHook = ''
            export JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -Dorg.lwjgl.openal.libname=${pkgs.openal}/lib/libopenal.so"
          '';
        };
      }
    );
}
