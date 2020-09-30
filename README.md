# firecracker-containerd in NixOS

Simplify the setup of firecracker with containerd on a Nix environment

# Usage

Use nix-shell or direnv to load the correct shell deps.

1. `nix-build firecracker-runtime.nix`
2. `result/bin/containerd`

In a new terminal

1. Pull the latest image of a container (alpine in this example).
```
sudo ctr --address /run/firecracker-containerd/containerd.sock images \
  pull --snapshotter devmapper \
  docker.io/library/alpine:latest
```

2. Run the container
```
 sudo ctr --address /run/firecracker-containerd/containerd.sock \                                                                                 ~/firecracker-containerd
  run \
  --snapshotter devmapper \
  --runtime aws.firecracker \
  --rm --tty --net-host \
  docker.io/library/alpine:latest alpine
```

Done! And the container is connected to the internet (test with `ping google.com`).