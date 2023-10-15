#!/bin/bash

# https://kind.sigs.k8s.io/docs/user/rootless/
# - Specficailly the cgroup bits on delegation

# https://www.redhat.com/sysadmin/mount-namespaces
# https://www.redhat.com/sysadmin/uts-namespace

# Create new network namespace
ip netns add test1

# Create veth
ip link del veth0

# Create the veth pair
ip link add veth0 type veth peer name veth1

# Move veth1 to the test1 namespace
ip link set veth1 netns test1

# Assign ULA IPv6 address to veth1 inside the test1 namespace
ip netns exec test1 ip addr add fc00:abcd::1/64 dev veth1
ip netns exec test1 ip link set veth1 up

# Assign ULA IPv6 address to veth0 in the default namespace
ip addr add fc00:abcd::2/64 dev veth0
ip link set veth0 up

ip netns exec test1 ip -6 route add default via fc00:abcd::2

# lo always down for some reason
ip netns exec test1 ip link set lo up

# Consider --cgroup

# Create the new namespace

#unshare --net=/var/run/netns/lab-0 --root /home/darrenchin/Downloads/bookworm-1 --pid --mount-proc --fork --cgroup

## Inside

exit 0

mkdir /dev

mknod -m 666 /dev/null c 1 3
mknod -m 666 /dev/zero c 1 5
mknod -m 666 /dev/random c 1 8
mknod -m 666 /dev/urandom c 1 9
mknod -m 666 /dev/tty c 5 0
mount -t sysfs sysfs /sys
mount -t cgroup2 none /sys/fs/cgroup
mount -t devtmpfs devtmpfs /dev
