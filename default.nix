{
  nixpkgs ? <nixpkgs>, system ? builtins.currentSystem
}:
with import nixpkgs { inherit system; };
stdenv.mkDerivation rec {
  name = "rapport-stage";
  version = "2017";
  buildInputs = [
      (texlive.combine {
        inherit (texlive) scheme-medium syntax todo appendix paralist csvsimple
        biblatex logreq xstring cleveref filehook;
      })
      pandoc
      biber
  ];

  src = builtins.filterSource (name: type:
    let baseName = baseNameOf (toString name); in !(
        (type == "directory" &&
        (baseName == ".git" ||
          baseName == "out"))))
    ./.;


  installPhase = ''
    mkdir -p $out/nix-support
    cp out/main.pdf $out/
    echo "file pdf $out/main.pdf" >> $out/nix-support/hydra-build-products
  '';
}

