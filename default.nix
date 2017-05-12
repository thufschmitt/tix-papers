{
  nixpkgs ? <nixpkgs>, system ? builtins.currentSystem
}:
with import nixpkgs { inherit system; };
stdenv.mkDerivation rec {
  name = "papers";
  version = "0.0";
  buildInputs = [
      (texlive.combine {
        inherit (texlive) scheme-medium syntax todo;
      })
      biber
  ];

  src = ./.;

  installPhase = ''
    cp out/main.pdf $out
  '';
}

