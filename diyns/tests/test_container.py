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

    _netns_name = 'tofu'
    _container_name = 'tofu'

    def test_instance(self):
        container = Container(TestContainer._container_name, TestContainer._netns_name)
        self.assertEqual(container.name, TestContainer._container_name)

    def test_create(self):
        netns = NetworkNamespace(TestContainer._netns_name)
        netns.create()
        container = Container(TestContainer._container_name, TestContainer._netns_name)
        container.create()

#        netns.delete()

if __name__ == '__main__':
    unittest.main()
