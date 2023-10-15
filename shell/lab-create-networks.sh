#!/bin/bash

set -e

leaf_vm_bridge="vmnet"

lab_network_names=(
    "leaf1"
    "leaf2"
    "leaf3"
    "spine1"
    "spine2"
)

declare -A lab_network
# "a" side of a veth is always upstream.
# Spine 1
lab_network["spine1_host_a_ipv6"]="fd73:6172:6168:a14::1"
lab_network["spine1_host_b_ipv6"]="fd73:6172:6168:a14::2"
lab_network["spine1_leaf1_a_ipv6"]="fd73:6172:6168:a16::1"
lab_network["spine1_leaf1_b_ipv6"]="fd73:6172:6168:a16::2"
lab_network["spine1_leaf2_a_ipv6"]="fd73:6172:6168:a17::1"
lab_network["spine1_leaf2_b_ipv6"]="fd73:6172:6168:a17::2"
lab_network["spine1_leaf3_a_ipv6"]="fd73:6172:6168:a18::1"
lab_network["spine1_leaf3_b_ipv6"]="fd73:6172:6168:a18::2"

# Spine 2
lab_network["spine2_host_a_ipv6"]="fd73:6172:6168:a15::1"
lab_network["spine2_host_b_ipv6"]="fd73:6172:6168:a15::2"
lab_network["spine2_leaf1_a_ipv6"]="fd73:6172:6168:a19::1"
lab_network["spine2_leaf1_b_ipv6"]="fd73:6172:6168:a19::2"
lab_network["spine2_leaf2_a_ipv6"]="fd73:6172:6168:a1a::1"
lab_network["spine2_leaf2_b_ipv6"]="fd73:6172:6168:a1a::2"
lab_network["spine2_leaf3_a_ipv6"]="fd73:6172:6168:a1b::1"
lab_network["spine2_leaf3_b_ipv6"]="fd73:6172:6168:a1b::2"

# Leaves
# These do not have IP pairings as the "b" side will be attached to a bridge.
lab_network["leaf1_vmnet_a_ipv6"]="fd73:6172:6168:a1c::1"
lab_network["leaf2_vmnet_a_ipv6"]="fd73:6172:6168:a1d::1"
lab_network["leaf3_vmnet_a_ipv6"]="fd73:6172:6168:a1e::1"

function create_network_namespace() {
    if [ ! -f /run/netns/${1} ]; then
        ip netns add ${1}
    fi
}

function configure_leaf() {
    # Bring lo up
    ip netns exec ${1} ip link set lo up

    # Bring up vmnet bridge
    if ! ip netns exec ${1} ip link show dev ${leaf_vm_bridge} >/dev/null ; then
        ip netns exec ${1} ip link add name ${leaf_vm_bridge} type bridge
    fi

    # Bring up veth
    if ! ip netns exec ${1} ip link show dev ${1}_vmnet_a >/dev/null ; then
        ip netns exec ${1} ip link add ${1}_vmnet_a type veth peer name ${1}_vmnet_b
        ip netns exec ${1} ip addr add ${lab_network["${1}_vmnet_a_ipv6"]}/64 dev ${1}_vmnet_a
        ip netns exec ${1} ip link set ${1}_vmnet_b master ${leaf_vm_bridge}
        ip netns exec ${1} ip link set ${1}_vmnet_a up
        ip netns exec ${1} ip link set ${1}_vmnet_b up
        ip netns exec ${1} ip link set ${leaf_vm_bridge} up
    fi
}

function configure_spine() {
    # Bring lo up
    ip netns exec ${1} ip link set lo up

    # host to ${1}
    if ! ip link show dev ${1}_host_a >/dev/null ; then
        ip link add ${1}_host_a type veth peer name ${1}_host_b
        ip link set ${1}_host_b netns ${1}
        ip addr add ${lab_network["${1}_host_a_ipv6"]}/64 dev ${1}_host_a
        ip netns exec ${1} ip addr add ${lab_network["${1}_host_b_ipv6"]}/64 dev ${1}_host_b
        ip link set ${1}_host_a up
        ip netns exec ${1} ip link set ${1}_host_b up
    fi

    # ${1} to leaf1
    if ! ip netns exec ${1} ip link show dev ${1}_leaf1_a >/dev/null; then
        ip netns exec ${1} ip link add ${1}_leaf1_a type veth peer name ${1}_leaf1_b
        ip netns exec ${1} ip link set ${1}_leaf1_b netns leaf1
        ip netns exec ${1} ip addr add ${lab_network["${1}_leaf1_a_ipv6"]}/64 dev ${1}_leaf1_a
        ip netns exec leaf1 ip addr add ${lab_network["${1}_leaf1_b_ipv6"]}/64 dev ${1}_leaf1_b
        ip netns exec ${1} ip link set ${1}_leaf1_a up
        ip netns exec leaf1 ip link set ${1}_leaf1_b up
    fi

    # ${1} to leaf2
    if ! ip netns exec ${1} ip link show dev ${1}_leaf2_a >/dev/null; then
        ip netns exec ${1} ip link add ${1}_leaf2_a type veth peer name ${1}_leaf2_b
        ip netns exec ${1} ip link set ${1}_leaf2_b netns leaf2
        ip netns exec ${1} ip addr add ${lab_network["${1}_leaf2_a_ipv6"]}/64 dev ${1}_leaf2_a
        ip netns exec leaf2 ip addr add ${lab_network["${1}_leaf2_b_ipv6"]}/64 dev ${1}_leaf2_b
        ip netns exec ${1} ip link set ${1}_leaf2_a up
        ip netns exec leaf2 ip link set ${1}_leaf2_b up
    fi
}

function main() {
    # Create the network namespaces first.
    #for lab_network_name in ${lab_network_names[@]}; do
    #    create_network_namespace ${lab_network_name}
    #done

    # Configure spines.
    configure_spine spine1
    configure_spine spine2

    # Configure leaves.
    configure_leaf leaf1
    configure_leaf leaf2
    configure_leaf leaf3
}

main
