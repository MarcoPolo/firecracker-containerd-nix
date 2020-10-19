{ pkgs ? import nix/nixpkgs.nix {} }:
pkgs.buildGoModule rec {
  pname = "cni-plugins";
  version = "0.0.1";
  src = pkgs.fetchFromGitHub {
    owner = "containernetworking";
    repo = "plugins";
    rev = "e78e6aa5b9fd7e3e66f0cb997152c44c2a4e43df";
    sha256 = "sha256:1q2b15bdf003rx9gmxrsspf4bjrng6gz3yl7wqp41sqymwdcwi2s";
    fetchSubmodules = true;
  };
  doCheck = false;
  vendorSha256 = null;
}
