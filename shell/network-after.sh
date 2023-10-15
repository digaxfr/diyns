#!/bin/bash

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
