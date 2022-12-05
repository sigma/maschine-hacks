{
  description = "Maschine hacks";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [
      flake-utils.lib.system.aarch64-darwin
      flake-utils.lib.system.x86_64-darwin
    ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        name = "maschine-hacks";
      in rec {
        defaultPackage = packages.maschine-hacks;
        packages.maschine-hacks = pkgs.stdenv.mkDerivation {
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
      }
    );
}
