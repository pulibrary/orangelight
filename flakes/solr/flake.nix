{
  description = "Solr";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];
    in (flake-utils.lib.eachSystem systems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "solr";
          version = "9.6.0";

          src = pkgs.fetchurl {
            url = "https://archive.apache.org/dist/solr/solr/${version}/solr-${version}.tgz";
            sha512 = "9c5b6c15db575468b2ddaf4538078a875bf15696ab2611db9d5190cf3d9c2aa6a24c303398231932a7ca85d7f5e441a24b3ef60f50547073167bc62a29b7c839";
          };

          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ pkgs.openjdk11 ];

          installPhase = ''
            mkdir -p $out
            cp -r * $out/

            wrapProgram $out/bin/solr \
              --set JAVA_HOME "${pkgs.openjdk11.home}"
          '';

          meta = with pkgs.lib; {
            description = "Solr";
            homepage = "https://solr.apache.org/";
            platforms = platforms.all;
          };
        };
      }
    )
  );
}
