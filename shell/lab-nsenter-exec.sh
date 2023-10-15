#!/bin/bash

set -e

ctr_lib_dir=/var/lib/lab-containers

if [ -z "${1}" ]; then
    echo "Pass in a container name."
    exit 1
fi

if [ ! -d ${ctr_lib_dir}/${1} ]; then
    echo "Container config/rootfs does not exist."
    exit 1
fi

# Add a check here for checking sleeper pid is expected.

set -x

nsenter --root=/proc/$(cat ${ctr_lib_dir}/${1}/sleeper.pid)/root --wd=/proc/$(cat ${ctr_lib_dir}/${1}/sleeper.pid)/root -a -t $(cat ${ctr_lib_dir}/${1}/sleeper.pid)

#nsenter --root=/proc/$(cat ${ctr_lib_dir}/${1}/sleeper.pid)/root --wd=/proc/$(cat ${ctr_lib_dir}/${1}/sleeper.pid)/root -a -t $(cat ${ctr_lib_dir}/${1}/sleeper.pid) /usr/sbin/sshd -D > /tmp/1.out 2> /tmp/2.out &
