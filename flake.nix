{
  description = "Maschine hacks";

  inputs.systems.url = "github:nix-systems/default";

  outputs = { self, nixpkgs, systems }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
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
      rec {
        packages = eachSystem (system: let
            pkgs = import nixpkgs { inherit system; };
          in {
            maschine-hacks = pkg pkgs;
          }
        );
        defaultPackage = eachSystem (system: packages.${system}.maschine-hacks);
      } // {
        overlays.default = (final: prev: {
          maschine-hacks = pkg prev;
        });
      };
}
