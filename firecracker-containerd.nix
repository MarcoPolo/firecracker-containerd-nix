# { pkgs ? import <nixpkgs> { } }:
# pkgs.stdenv.mkDerivation {
  # name = "firecracker-containerd";
  # buildInputs = [pkgs.go];
  # buildPhase = ''
    # cp -r $src/* .
    # go build firecracker-control/cmd/containerd/main.go 
  # '';
  # installPhase = ''
    # mkdir -p $out/bin
    # cp firecracker-control/cmd/containerd/firecracker-containerd $out/bin/
  # '';
  # src = pkgs.fetchFromGitHub {
    # owner = "firecracker-microvm";
    # repo = "firecracker-containerd";
    # rev = "1cad9d98086719b8247b9cf2413988debfae9a95";
    # sha256 = "sha256:1wfs8jaaa8hzrr3kz6knw0p2zvq7rvh4wk7k468kpnl0zzsgvybw";
    # fetchSubmodules = true;
  # };
# }

{ system ? builtins.currentSystem, pkgs ? import nix/nixpkgs.nix {} }:
pkgs.buildGoModule rec {
  pname = "firecracker-containerd";
  version = "0.0.1";
  patches = [./more-memory.patch];
  src = pkgs.fetchFromGitHub {
    owner = "firecracker-microvm";
    repo = "firecracker-containerd";
    rev = "1cad9d98086719b8247b9cf2413988debfae9a95";
    sha256 = "1f578bmrpacfbqj37kawl5661lpac9xxjqcbzcrhx48mymcrzyym";
    fetchSubmodules = true;
    # sha256 = pkgs.lib.fakeSha256;
    # rev = "v${version}";
    # sha256 = "sha256:12lka6mxrl0my98fxylfqcj87214p0hnfpjp068agqrv4473054n";
    # rev = "c17a99c7bbff8b9d1e96594e5f6356de61bb98fd";
    # sha256 = "sha256:0l5yslaic02pr3b45f85ydz1w9891gy63068p5v7ycy9irzvhv5v";
  };
  # buildPhase = ''
  #   go build firecracker-control/cmd/containerd/main.go 
  # '';

  doCheck = false;
  # buildInputs = [pkgs.tree];
  # subPackages = [ "firecracker-control/cmd/containerd"];
  # subPackages = [ "agent"];
  # postInstall = ''
  #   cd firecracker-control/cmd/containerd
  #   # ${pkgs.tree}/bin/tree $GOPATH
  #   make firecracker-ctr
  #   ls .
  #   # mkdir -p $out/bin
  #   # ${pkgs.tree}/bin/tree .
  #   # ${pkgs.tree}/bin/tree $GOPATH 
  # '';
  postInstall = ''
    mv $out/bin/runtime $out/bin/containerd-shim-aws-firecracker
    mv $out/bin/containerd $out/bin/firecracker-containerd
  '';

  vendorSha256 = "sha256:0bx878znsbfjvpim6maml6h92k4jv58mwaj2gnv1g252xc6p7dvs";
  # buildInputs = [ pkgs.makeWrapper ];
  # patches = [ ./configurable-cni-paths.diff ];
  # preFixup = ''
  #   wrapProgram $out/bin/ignited \
  #           --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
  #           --set NIX_REDIRECTS "/opt/cni/bin=${pkgs.cni-plugins}"
  #   wrapProgram $out/bin/ignite \
  #           --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
  #           --set NIX_REDIRECTS "/opt/cni/bin=${pkgs.cni-plugins}"
  # '';
}
