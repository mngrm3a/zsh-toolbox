{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      pkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      hsPkgsFor = forAllSystems (system: (import nixpkgs { inherit system; }).haskellPackages);
      mkPackage = hsPkgs: hsPkgs.callCabal2nix "zsh-toolbox" ./. { };
    in
    {
      overlays.default = final: prev: { zsh-toolbox = mkPackage final.haskellPackages; };
      packages = forAllSystems (system: {
        default = mkPackage hsPkgsFor.${system};
      });
      devShells = forAllSystems (system: {
        default =
          let
            pkgs = pkgsFor.${system};
            hsPkgs = hsPkgsFor.${system};
            mkLink = pkgs.writeShellScriptBin "mk-link" "ln -s $(cabal list-bin zsh-toolbox-exe) $1";
          in
          with hsPkgs;
          shellFor {
            packages = p: [ self.packages.${system}.default ];
            withHoogle = true;
            buildInputs = [
              haskell-language-server
              ghcid
              hpack
              cabal-install
              stack
              mkLink
            ];
          };
      });
    };
}
