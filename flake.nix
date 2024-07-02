{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hsPkgs = pkgs.haskell.packages."ghc965";
        hsTools = with hsPkgs; [
          ghc
          ghcid
          haskell-language-server
          hpack
          cabal-install
          stack
        ];
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nil
            pkgs.zlib
          ] ++ hsTools;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath hsTools;
        };
      }
    );
}
