{ pkgs ? import nix/nixpkgs.nix {}
, firecracker ? pkgs.callPackage (import ./firecracker.nix) {}
, firecracker-containerd ? import ./firecracker-containerd.nix { inherit pkgs; }
, fc-cni-plugins ? import ./fc-cni-plugins.nix { inherit pkgs; }
, cni-conf ? import ./cni-conf.nix { inherit pkgs; }
, state-dir ? "/run/firecracker-containerd"
, lib-dir ? "/var/lib/firecracker-containerd"
, devmapper-dir ? "${lib-dir}/snapshotter/devmapper"
, dev-pool ? "fc-dev-thinpool"
}:

let
  firecracker-runtime-json = builtins.toJSON {
    firecracker_binary_path = "${firecracker}/bin/firecracker";
    kernel_args = "console=ttyS0 noapic reboot=k panic=1 pci=off nomodules ro systemd.journald.forward_to_console systemd.unit=firecracker.target init=/sbin/overlay-init";
    kernel_image_path = ./hello-vmlinux.bin;
    root_drive = ./rootfs.img;
    default_network_interfaces = [
      {
        CNIConfig = {
          NetworkName = "fcnet";
          InterfaceName = "veth0";
          ConfDir = "${cni-conf}";
          BinPath = [ "${fc-cni-plugins}/bin" ];
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
    root = "${lib-dir}/containerd"
    state = "${state-dir}"
    [grpc]
      address = "${state-dir}/containerd.sock"
    [plugins]
      [plugins.devmapper]
        pool_name = "${dev-pool}" 
        base_image_size = "10GB"
        root_path = "${devmapper-dir}" 

    [debug]
      level = "debug"'';
  containerd-wrapper = ''
    #!/usr/bin/env bash
    DIR=$(realpath $(dirname $0))
    PATH=${pkgs.utillinux + "/bin"}:${pkgs.lvm2 + "/bin"}:$PATH DEVPOOL="${dev-pool}" DEVMAPPER_DIR="${devmapper-dir}" $DIR/setup_thinpool.sh
    sleep 1
    PATH=$PATH FIRECRACKER_CONTAINERD_RUNTIME_CONFIG_PATH="$DIR/../firecracker-runtime.json" ${firecracker-containerd}/bin/firecracker-containerd --config=${config-toml}
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
      echo '${containerd-wrapper}' > $out/bin/fc-containerd
      cp $src $out/bin/$(stripHash $src)
      chmod a+x $out/bin/fc-containerd
      # cp bin/* $out/bin/
    '';
  }
