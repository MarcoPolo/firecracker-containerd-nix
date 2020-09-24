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
    # sha256 = pkgs.lib.fakeSha256;
    # rev = "v${version}";
    # sha256 = "sha256:12lka6mxrl0my98fxylfqcj87214p0hnfpjp068agqrv4473054n";
    # rev = "c17a99c7bbff8b9d1e96594e5f6356de61bb98fd";
    # sha256 = "sha256:0l5yslaic02pr3b45f85ydz1w9891gy63068p5v7ycy9irzvhv5v";
  };
  doCheck = false;
  vendorSha256 = null;
}
