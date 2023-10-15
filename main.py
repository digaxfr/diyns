#!/usr/bin/env python3
"""
Stub.
"""

from diyns.container import Container
from diyns.netns import NetworkNamespace

netns_spine1 = NetworkNamespace('spine1')
netns_spine1.create()

ctr_spine1 = Container('spine1', netns_spine1.name)
ctr_spine1.up()
