#!/bin/bash

# https://kind.sigs.k8s.io/docs/user/rootless/
# - Specficailly the cgroup bits on delegation

# https://www.redhat.com/sysadmin/mount-namespaces
# https://www.redhat.com/sysadmin/uts-namespace

# Create new network namespace
ip netns add test1

ip6tables -A FORWARD -s fc00:abcd::/64 -j ACCEPT
ip6tables -t nat -A POSTROUTING -s fc00:abcd::/64 -o enP4p65s0 -j MASQUERADE
