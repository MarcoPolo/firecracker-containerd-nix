{ pkgs ? import nix/nixpkgs.nix {} }:
let
  fcnet-conflist = builtins.toFile "fcnet.conflist" ''
    {
      "cniVersion": "0.4.0",
      "name": "fcnet",
      "plugins": [
        {
          "type": "bridge",
          "bridge": "fc-br0",
          "isDefaultGateway": true,
          "forceAddress": false,
          "ipMasq": true,
          "hairpinMode": true,
          "mtu": 1500,
          "ipam": {
            "type": "host-local",
            "subnet": "192.168.1.0/24",
            "resolvConf": "/etc/resolv.conf"
          },
          "dns": {
            "nameservers": [ "1.1.1.1", "8.8.8.8" ]
          }
        },
        {
          "type": "firewall"
        },
        {
          "type": "tc-redirect-tap"
        }
      ]
    }'';
in
pkgs.stdenv.mkDerivation {
  name = "cni-conf";
  src = fcnet-conflist;
  dontUnpack = true;
  installPhase = ''
    mkdir $out
    cp $src $out/$(stripHash $src)
  '';
}
