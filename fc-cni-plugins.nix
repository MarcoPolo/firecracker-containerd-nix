{ pkgs ? import nix/nixpkgs.nix {} }:
let
  cni-plugins = import ./cni-plugins.nix { inherit pkgs; };
  tc-redirect-tap = import ./tc-redirect-tap.nix { inherit pkgs; };
  allowed-plugins = [
    "bridge"
    "firewall"
    "tc-redirect-tap"
    "host-local"
  ];

in
pkgs.stdenv.mkDerivation {
  name = "fc-cni-plugins";
  # buildInputs = [cni-plugins tc-redirect-tap];
  srcs = [ cni-plugins tc-redirect-tap ];
  unpackPhase = ''
    for _src in $srcs; do
      cp "$_src"/bin/* ./
    done
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${if builtins.length allowed-plugins > 0 then builtins.concatStringsSep " " allowed-plugins else "*"} $out/bin/
  '';
}
