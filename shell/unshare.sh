#!/bin/bash

#unshare --net=/var/run/netns/test1  --root /home/darrenchin/Downloads/container1/merged --pid --mount-proc --fork --cgroup --uts --ipc --mount

#unshare --net=/var/run/netns/test1  --root /home/darrenchin/Downloads/container1/native --pid --mount-proc --fork --cgroup --uts --ipc --mount /tini /bin/bash

#unshare --net=/var/run/netns/test1  --root /home/darrenchin/Downloads/container1/native --pid --mount-proc --fork --cgroup --uts --ipc --mount /init

unshare --net=/var/run/netns/test1  --root /var/lib/lab-containers/ctr001/rootfs --pid --mount-proc --fork --cgroup --uts --ipc --mount /lib/systemd/systemd
#unshare --net=/var/run/netns/test1  --root /var/lib/lab-containers/ctr001/rootfs --pid --mount-proc --fork --cgroup --uts --ipc --mount /bin/bash
