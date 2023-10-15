"""
Unit tests for containers and its various other namespaces.
"""

import subprocess
import time
import unittest
from datetime import datetime
from diyns.container import Container
from diyns.netns import NetworkNamespace

class TestContainer(unittest.TestCase):

    _netns_name = 'tofutests3'
    _container_name = 'tofu'
    _container_name_never = 'thiswillneverexisthopefully'

    def test_instance(self):
        container = Container(TestContainer._container_name, TestContainer._netns_name)
        self.assertEqual(container.name, TestContainer._container_name)

    def test_down(self):
        container = Container(TestContainer._container_name_never, TestContainer._netns_name)
        container.down()

    def test_up_down(self):
        netns = NetworkNamespace(TestContainer._netns_name)
        netns.create()
        container = Container(TestContainer._container_name, TestContainer._netns_name)
        container.up()
        container.down()
        netns.delete()

if __name__ == '__main__':
    unittest.main()
