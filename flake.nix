{
  description = "Ardees";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, flake-utils, devshell, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default = let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [ devshell.overlays.default ];

          config.permittedInsecurePackages = [ ];
        };
      in pkgs.devshell.mkShell {
        name = "ardees.dev";
        commands = [{
          name = "devspace";
          category = "devshell";
          help = "Opens dev workspace";
          command = "zellij -l layout.kdl";
        }];
        packages = [
          pkgs.pkg-config
          pkgs.gcc
          pkgs.sqlite
          pkgs.gnumake
          pkgs.python313
          pkgs.libyaml.dev
          pkgs.openssl_3_2.dev
          pkgs.postgresql_16.dev
          pkgs.autoconf269
          pkgs.automake
          pkgs.autogen
          pkgs.libtool
          pkgs.libffi.dev
          pkgs.gnum4
          pkgs.secp256k1
        ];
        env = [
          {
            name = "PKG_CONFIG_PATH";
            value =
              "${pkgs.pkg-config}:${pkgs.openssl_3_2.dev}/lib/pkgconfig:${pkgs.libyaml.dev}/lib/pkgconfig:${pkgs.postgresql_16.dev}/lib/pkgconfig:${pkgs.libffi.dev}/lib/pkgconfig:${pkgs.secp256k1}/lib/pkgconfig";
          }
          {
            name = "LIBTOOL";
            value = "${pkgs.libtool}";
          }
          {
            name = "NIXPKGS_ALLOW_INSECURE";
            value = "1";
          }
        ];
      };
    });
}
