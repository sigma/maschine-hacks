{
  description = "Maschine hacks";

  # flake-parts
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    let
      name = "maschine-hacks";
      pkg = pkgs: pkgs.stdenv.mkDerivation {
        pname = name;
        version = "0.1";
        src = ./.;

        buildPhase = ''
            cat <<EOF > maschine-patch
              #!/bin/sh
              cd "/Applications/Native Instruments/Maschine 2/Maschine 2.app/Contents/Resources/Scripts/Maschine"

              ln -sf $src/MaschineStudioSigma
              patch -s --forward -r /dev/null -p1 < $src/installer.patch || true
            EOF

            cat <<EOF > maschine-unpatch
              #!/bin/sh
              cd "/Applications/Native Instruments/Maschine 2/Maschine 2.app/Contents/Resources/Scripts/Maschine"

              rm -f MaschineStudioSigma
              patch -R -p1 < $src/installer.patch
            EOF
          '';
        dontUnpack = true;

        installPhase = ''
            mkdir -p $out/bin
            install -m 755 maschine-patch $out/bin/maschine-patch
            install -m 755 maschine-unpatch $out/bin/maschine-unpatch
          '';
      };
    in
      flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        perSystem = {config, system, pkgs, inputs', ...}: {
          packages = let
            default = pkg pkgs;
          in {
            inherit default;
            maschine-hacks = default;
          };
        };
      } // {
        overlays.default = (final: prev: {
          maschine-hacks = pkg prev;
        });
      };
}
