#!/bin/bash

set -e

ctr_lib_dir=/var/lib/lab-containers
sleeper_ps_args="sleep infinity"
containers=(
    "leaf1"
    "leaf2"
    "leaf3"
    "spine1"
    "spine2"
)

function bind_rootfs() {
    if ! findmnt ${ctr_lib_dir}/${1}/rootfs >/dev/null; then
        mount --bind ${ctr_lib_dir}/${1}/rootfs ${ctr_lib_dir}/${1}/rootfs
    fi
}

function create_rootfs() {
    # Check for rootfs dir.
    if [ ! -d "${ctr_lib_dir}/${1}/rootfs" ]; then
        echo "rootfs for container '${1}' not found. Creating..."
        mkdir -p "${ctr_lib_dir}/${1}/rootfs"
        cp -a "${ctr_lib_dir}/base/rootfs" "${ctr_lib_dir}/${1}/"
    fi

    # Do these every time.
    cp /etc/resolv.conf "${ctr_lib_dir}/${1}/rootfs/etc/resolv.conf"
    echo "${1}" > "${ctr_lib_dir}/${1}/rootfs/etc/hostname"
    tee "${ctr_lib_dir}/${1}/rootfs/etc/hosts" << EOF
127.0.0.1 localhost
127.0.1.1 ${1}
EOF
}

function container_down() {
    if [ -f "${ctr_lib_dir}/${1}/sleeper.pid" ]; then
        ps_check_sleeper=$(ps -p $(cat ${ctr_lib_dir}/${1}/sleeper.pid) -o args=) || true
        if [ "${ps_check_sleeper}" == "${sleeper_ps_args}" ]; then
            echo "Killing '${1}' with pid $(cat ${ctr_lib_dir}/${1}/sleeper.pid)"
            kill -9 $(cat "${ctr_lib_dir}/${1}/sleeper.pid") || true
            # Need to add a loop here to make sure it is killed before moving on.
        fi
    fi
}

function container_up() {
    # Check if sleeper is currently running
    if [ -f "${ctr_lib_dir}/${1}/sleeper.pid" ]; then
        ps_check_sleeper=$(ps -p $(cat ${ctr_lib_dir}/${1}/sleeper.pid) -o args=) || true

        if [ "${ps_check_sleeper}" == "${sleeper_ps_args}" ]; then
            echo "Sleeper running already."
            return 0
        fi
    fi

    # DEBUG: Host Networking
    # unshare --root ${ctr_lib_dir}/${1}/rootfs --pid --mount-proc --fork --cgroup --uts --ipc --mount /bin/bash -c "sleep infinity" > ${ctr_lib_dir}/${1}/stdout.log 2>${ctr_lib_dir}/${1}/stderr.log &

    unshare --root ${ctr_lib_dir}/${1}/rootfs --net=/var/run/netns/${1} --pid --mount-proc --fork --cgroup --uts --ipc --mount /bin/bash -c "sleep infinity" > ${ctr_lib_dir}/${1}/stdout.log 2>${ctr_lib_dir}/${1}/stderr.log &

    unshare_pid=$!
    echo ${unshare_pid} > ${ctr_lib_dir}/${1}/unshare.pid

    child_pid=$(ps --ppid ${unshare_pid} -o pid= | tr -d ' ')
    echo ${child_pid} > ${ctr_lib_dir}/${1}/sleeper.pid
    echo "${1} started"
    return 0
}

function configure_mounts() {
    child_pid=$(cat "${ctr_lib_dir}/${1}/sleeper.pid")

    if [ $(check_mount "${child_pid}" "/run") == "unmounted" ]; then
        nsenter -t ${child_pid} -a --root=/proc/${child_pid}/root mount -t tmpfs -o size=256M,mode=0755 tmpfs /run
    fi

    if [ $(check_mount "${child_pid}" "/sys") == "unmounted" ]; then
        nsenter -t ${child_pid} -a --root=/proc/${child_pid}/root mount -t sysfs sysfs /sys
    fi

    if [ $(check_mount "${child_pid}" "/dev") == "unmounted" ]; then
        nsenter -t ${child_pid} -a --root=/proc/${child_pid}/root mkdir -p /dev
        nsenter -t ${child_pid} -a --root=/proc/${child_pid}/root mount -t devtmpfs devtmpfs /dev
    fi

    if [ $(check_mount "${child_pid}" "/sys/fs/cgroup") == "unmounted" ]; then
        nsenter -t ${child_pid} -a --root=/proc/${child_pid}/root mount -t cgroup2 none /sys/fs/cgroup
    fi

    if [ $(check_mount "${child_pid}" "/dev/pts") == "unmounted" ]; then
        nsenter -t ${child_pid} -a --root=/proc/${child_pid}/root mount -t devpts devpts /dev/pts
    fi
}

function configure_os() {
    child_pid=$(cat "${ctr_lib_dir}/${1}/sleeper.pid")

    nsenter -t ${child_pid} -a --root=/proc/${child_pid}/root hostname ${1}
    nsenter -t ${child_pid} -a --root=/proc/${child_pid}/root ssh-keygen -A
}

function check_mount() {
    if nsenter -t ${child_pid} -a --root=/proc/${1}/root findmnt "${2}" >/dev/null; then
        echo "mounted"
    else
        echo "unmounted"
    fi
}

function create_network_namespace() {
    if [ ! -f /run/netns/${1} ]; then
        ip netns add ${1}
    fi
}

function delete_network_namespace() {
    if [ -f /run/netns/${1} ]; then
        ip netns delete ${1}
    fi
}

function start_sshd() {
    child_pid=$(cat "${ctr_lib_dir}/${1}/sleeper.pid")

    nsenter -t ${child_pid} -a --root=/proc/${child_pid}/root hostname ${1}
}

function main() {
    case "${1}" in
        "up")
            for container in "${containers[@]}"; do
                create_network_namespace "${container}"
                create_rootfs "${container}"
                bind_rootfs "${container}"
                container_up "${container}"
                configure_mounts "${container}"
                configure_os "${container}"
#                start_sshd "${container}"
            done
            ;;
        "down")
            for container in "${containers[@]}"; do
                container_down "${container}"
                sleep 1
                delete_network_namespace "${container}"
            done
            ;;
        *)
            echo "Invalid"
            exit 1
            ;;
    esac
}

# Check ARG1.
if [ "${1}" != "up" ] && [ "${1}" != "down" ]; then
    echo "Usage: ${0} up|down"
    exit 1
fi

main "${1}"

# TODO:
# Network, resolv.conf, hostname
# SSH init
# cgroups

# Subtree controllers are controled by:
# cat /sys/fs/cgroup/cgroup.subtree_control
# cpuset ...
# echo "+cpu +memory -io" > cgroup.subtree_control
