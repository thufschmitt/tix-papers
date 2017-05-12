let pkgs = import <nixpkgs>; in
{
  "paper.pdf" = import ./default.nix;
}
