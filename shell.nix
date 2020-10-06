{pkgs ? import nix/nixpkgs.nix {}}: # import the sources
let firecracker-containerd = import ./firecracker-containerd.nix { inherit pkgs; };
  firecracker = pkgs.callPackage (import ./firecracker.nix) {};
  cni-plugins = (import ./cni-plugins.nix { inherit pkgs;});
  tc-redirect-tap = (import ./tc-redirect-tap.nix { inherit pkgs;});
  firecracker-runtime = (import ./firecracker-runtime.nix { inherit pkgs;});
in 
pkgs.mkShell {
buildInputs = [pkgs.containerd pkgs.bc firecracker-containerd firecracker cni-plugins tc-redirect-tap firecracker-runtime];
}
