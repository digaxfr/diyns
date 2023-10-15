# Namespace Fun

Doing whacky configurations like nested k3s/kube instances inside a container built using `unshare`. The idea is to
mimic `k3d` without Docker, and also to learn a bit along the way.

* Moving the unshare call to the root cgroup made it all work. This is likely due to the nesting under user, certain
delegations not working (cgroup.controllers and cgroup.subtree_control)
  * After dropping into a root shell, move my shell into root cgroup
    * echo $$ > /sys/fs/cgroup/cgroup.procs

* Set up rootfs, native fs only. No overlay.
  * mount --bind /rootfs /rootfs
* Spawn new shell, move the cgroup into root or less-restrictive cgroup
* Stand up network namespace
* sysctl forwarding
* Start unshare
* Stand up veth
* Set up sysfs, cgroup, etc. with mk.sh
* Profit?
* Make sure iptables is set up on the outside/host system


* Create the cgroup slice
* Set up the cgroup.subtree_control
    echo "+cpuset +cpu +io +pids +memory" > cgroup.subtree_control (inside lab.slice)
  * Remember that the current cgroup slice has to be empty of any processes to be able to modify them
  * So create a new nested one, move all procs into it, and then set the subree_controll on the parent, and it should propagate down

* sudo systemd-run --slice lab bash

* s6-init used


# rootfs
https://github.com/debuerreotype/docker-debian-artifacts/tree/9af04cb525315a7bee9865c127afd966b92bf34d/bookworm


## v2

* Plumbing of network namespaces/leaf/spine is done.
* Next is to work on BGP configuration starting from Host OS, Spine, then Leaf.
  * Need to work on setting default gateway on peering.

* nsenter -a -t <pid> --root=/proc/<pid>/root

* It turns out, the network ns devices have to be added back in when we unshare the first thing into it. Not sure why?
