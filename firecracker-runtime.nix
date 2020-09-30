{ pkgs ? import nix/nixpkgs.nix {}
, firecracker ? pkgs.callPackage (import ./firecracker.nix) {}
, firecracker-containerd ? import ./firecracker-containerd.nix { inherit pkgs; }
, fc-cni-plugins ? import ./fc-cni-plugins.nix { inherit pkgs; }
, cni-conf ? import ./cni-conf.nix { inherit pkgs; }
}:

let
  firecracker-runtime-json = builtins.toJSON {
    firecracker_binary_path = "${firecracker}/bin/firecracker";
    kernel_args = "console=ttyS0 noapic reboot=k panic=1 pci=off nomodules ro systemd.journald.forward_to_console systemd.unit=firecracker.target init=/sbin/overlay-init";
    kernel_image_path = "/home/marco/firecracker-containerd/hello-vmlinux.bin";
    root_drive = "/home/marco/firecracker-containerd/rootfs.img";
    default_network_interfaces = [
      {
        CNIConfig = {
          NetworkName = "fcnet";
          InterfaceName = "veth0";
          ConfDir = "${cni-conf}";
          BinPath = ["${fc-cni-plugins}/bin"];
        };
      }
    ];
    cpu_template = "T2";
    log_levels = [ "debug" ];
    metrics_fifo = "fc-metrics.fifo";
  };
  firecracker-runtime-path = builtins.toFile "firecracker-runtime.json" firecracker-runtime-json;
  config-toml = builtins.toFile "config.toml" ''
    disabled_plugins = ["cri"]
    root = "/var/lib/firecracker-containerd/containerd"
    state = "/run/firecracker-containerd"
    [grpc]
      address = "/run/firecracker-containerd/containerd.sock"
    [plugins]
      [plugins.devmapper]
        pool_name = "fc-dev-thinpool"
        base_image_size = "10GB"
        root_path = "/var/lib/firecracker-containerd/snapshotter/devmapper"

    [debug]
      level = "debug"'';
  containerd-wrapper = ''
    #!/usr/bin/env bash
    DIR=$(realpath $(dirname $0))
    sudo $DIR/setup_thinpool.sh
    sudo PATH=$PATH FIRECRACKER_CONTAINERD_RUNTIME_CONFIG_PATH="$DIR/../firecracker-runtime.json" ${firecracker-containerd}/bin/firecracker-containerd --config=${config-toml}
  '';
    in
    pkgs.stdenv.mkDerivation
    {
    name = "firecracker-runtime";
  src = ./setup_thinpool.sh;
  # unpackPhase = " ";
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin/
    echo '${firecracker-runtime-json}' > $out/firecracker-runtime.json
    echo '${containerd-wrapper}' > $out/bin/containerd
    cp $src $out/bin/$(stripHash $src)
    chmod a+x $out/bin/containerd
    # cp bin/* $out/bin/
  '';
  # " firecracker-runtime.json "
  # (
  #   builtins.toJSON {
  #     firecracker_binary_path = "${firecracker}/bin/firecracker";
  #   }
  # );
  }
# {
#   "firecracker_binary_path": "/nix/store/g0vclp4ffymb94clrl6118rqq266q0yb-firecracker-0.22.0/bin/firecracker",
#   "kernel_args": "console=ttyS0 noapic reboot=k panic=1 pci=off nomodules ro systemd.journald.forward_to_console systemd.unit=firecracker.target init=/sbin/overlay-init",
#   "kernel_image_path": "/home/marco/firecracker-containerd/hello-vmlinux.bin",
#   "root_drive": "/home/marco/firecracker-containerd/rootfs.img",
#   "default_network_interfaces": [
#     {
#       "CNIConfig": {
#         "NetworkName": "fcnet",
#         "InterfaceName": "veth0"
#       }
#     }
#   ],
#   "cpu_template": "T2",
#   "log_levels": ["debug"],
#   "metrics_fifo": "fc-metrics.fifo"
# }
