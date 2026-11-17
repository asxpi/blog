{
  description = "blog.asxp.io — static blog (Zola)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (nixpkgs) lib;
    in
    {
      # The built site: the files nginx serves
      packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {
        pname = "blog";
        version = self.shortRev or self.dirtyShortRev or "dev";
        src = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.unions [
            ./config.toml
            ./content
            ./static
            ./templates
          ];
        };
        nativeBuildInputs = [ pkgs.zola ];
        # zola 0.23 builds its HTTP client at start and panics without
        # CA certificates, though the site fetches nothing
        env.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        buildPhase = "zola build --output-dir $out";
        dontInstall = true;
      };

      # services.blog: an nginx virtual host serving the site on a port;
      # TLS and the public name are the proxy's (Traefik on asxpio-ops)
      nixosModules.default =
        { config, lib, ... }:
        let
          cfg = config.services.blog;
        in
        {
          options.services.blog = {
            enable = lib.mkEnableOption "blog.asxp.io";
            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${system}.default;
              defaultText = lib.literalExpression "the blog flake's package";
            };
            port = lib.mkOption {
              type = lib.types.port;
              default = 8081;
            };
          };
          config = lib.mkIf cfg.enable {
            services.nginx = {
              enable = true;
              virtualHosts."blog.asxp.io" = {
                listen = [
                  {
                    addr = "0.0.0.0";
                    inherit (cfg) port;
                  }
                ];
                root = cfg.package;
                extraConfig = "error_page 404 /404.html;";
                locations."/".tryFiles = "$uri $uri/ =404";
                locations."~* \\.(css|png|svg|xml|ico)$".extraConfig = "expires 1h;";
              };
            };
          };
        };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.zola ];
        shellHook = ''
          echo "blog dev shell ready"
          echo "  zola serve   - live-reload preview on http://127.0.0.1:1111"
        '';
      };
    };
}
