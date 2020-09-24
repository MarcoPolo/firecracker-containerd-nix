{ system ? builtins.currentSystem, pkgs ? import nix/nixpkgs.nix {} }:
pkgs.buildGoModule rec {
  pname = "tc-redirect-tap";
  version = "0.0.1";
  src = pkgs.fetchFromGitHub {
    owner = "firecracker-microvm";
    repo = "firecracker-go-sdk";
    rev = "47e0f2c1287195380028c391b4ba9f46c1d8b5e9";
    sha256 = "sha256:0l08n24f2p8lf4467z0yd621vm0k5zks7d3ga94mcfg1k721sxnn";
    fetchSubmodules = true;
    # sha256 = pkgs.lib.fakeSha256;
    # rev = "v${version}";
    # sha256 = "sha256:12lka6mxrl0my98fxylfqcj87214p0hnfpjp068agqrv4473054n";
    # rev = "c17a99c7bbff8b9d1e96594e5f6356de61bb98fd";
    # sha256 = "sha256:0l5yslaic02pr3b45f85ydz1w9891gy63068p5v7ycy9irzvhv5v";
  };
  subPackages = ["./cni/cmd/tc-redirect-tap"];
  doCheck = false;
  vendorSha256 = "sha256:030z281jmfprrljbikhg7i7m1jqk5y5gsl7krf448652yynmmsl3";
}
