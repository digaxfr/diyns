#!/bin/bash

if [ -z "${1}" ]; then
    echo "Pass in a PID"
    exit 1
fi

nsenter -t ${1} -a --root=/proc/${1}/root mkdir -p /dev
#nsenter -t ${1} -a --root=/proc/${1}/root mknod -m 666 /dev/null c 1 3
#nsenter -t ${1} -a --root=/proc/${1}/root mknod -m 666 /dev/zero c 1 5
#nsenter -t ${1} -a --root=/proc/${1}/root mknod -m 666 /dev/random c 1 8
#nsenter -t ${1} -a --root=/proc/${1}/root mknod -m 666 /dev/urandom c 1 9
#nsenter -t ${1} -a --root=/proc/${1}/root mknod -m 666 /dev/tty c 5 0

# sysfs can be done outside
nsenter -t ${1} -a --root=/proc/${1}/root mount -t sysfs sysfs /sys
#mount -t sysfs sysfs /proc/${1}/root/sys
# dev can be done outside
#mount -t devtmpfs devtmpfs /proc/${1}/root/dev
nsenter -t ${1} -a --root=/proc/${1}/root mount -t devtmpfs devtmpfs /dev
# cgroup has to be inside
nsenter -t ${1} -a --root=/proc/${1}/root mount -t cgroup2 none /sys/fs/cgroup

# Subtree controllers are controled by:
# cat /sys/fs/cgroup/cgroup.subtree_control
# cpuset ...
# echo "+cpu +memory -io" > cgroup.subtree_control
