{
  nixpkgs ? <nixpkgs>, system ? builtins.currentSystem
}:
with import nixpkgs { inherit system; };
stdenv.mkDerivation rec {
  name = "papers.pdf";
  version = "0.0";
  buildInputs = [
      (texlive.combine {
        inherit (texlive) scheme-medium syntax todo;
      })
      biber
  ];

  src = ./.;

  installPhase = ''
    mkdir -p $out/nix-support
    cp out/main.pdf $out/
    echo "file pdf $out/main.pdf" >> $out/nix-support/hydra-build-products
  '';
}

