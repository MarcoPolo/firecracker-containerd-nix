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


# Thoughts on future work:

1. Define a spec file (like docker compose)
2. Use that spec file to create the worker nodes
3. Query worker nodes to find their ip addresses
4. start the control node with the ip addresses


Other idea

use nix's docker builder image to create custom images.