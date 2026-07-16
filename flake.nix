{
  description = "blog.asxp.io — static blog (Zola)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.zola
        ];

        shellHook = ''
          echo "blog dev shell ready"
          echo "  zola serve   - live-reload preview on http://127.0.0.1:1111"
        '';
      };
    };
}
