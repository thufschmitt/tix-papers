{
  nixpkgs ? <nixpkgs>, system ? builtins.currentSystem
}:
with import nixpkgs { inherit system; };
let markdown_latest =
  stdenv.mkDerivation rec {
    version = "2.5.3";
    pname = "markdown";
    name = "${pname}-${version}";
    tlType = "run";
    src = fetchurl {
      url = "http://mirrors.ctan.org/install/macros/generic/markdown.tds.zip";
      sha256 = "08qvgz4p6vymh0a891h1g25xqhjddkrk4429nccmw499c0bi15vj";
    };

    buildInputs = [ unzip ];

    # Multiple files problem
    unpackPhase = ''
      mkdir markdown
      cd markdown
      unzip $src
    '';

    installPhase = "cp -r . $out";
    phases = ["unpackPhase" "patchPhase" "installPhase"];

    meta = {
      branch = "3";
      platforms = stdenv.lib.platforms.unix;
    };
  };
in
stdenv.mkDerivation rec {
  name = "rapport-stage";
  version = "2017";
  buildInputs = [
      (texlive.combine {
        inherit (texlive) scheme-medium syntax todo appendix paralist csvsimple;
        markdown = { pkgs = [ markdown_latest ]; };
      })
  ];

  src = ./.;

  installPhase = ''
    mkdir -p $out/nix-support
    cp out/main.pdf $out/
    echo "file pdf $out/main.pdf" >> $out/nix-support/hydra-build-products
  '';
}

