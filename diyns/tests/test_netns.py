"""
Unit tests for network namespaces.
"""

import subprocess
import time
import unittest
from datetime import datetime
from diyns.netns import NetworkNamespace

class TestNetworkNamespace(unittest.TestCase):
    def test_print(self):
        ns = NetworkNamespace('tofu')
        self.assertEqual(ns.__str__(), '{"name": "tofu"}')

    def test_create_delete(self):
        netns_name = str(datetime.now().timestamp())
        ns = NetworkNamespace(netns_name)
        ns.create()
        time.sleep(1)
        ns.delete()

    def test_create_exception(self):
        ns = NetworkNamespace('\/')
        with self.assertRaises(subprocess.CalledProcessError) as context:
            ns.create()

    def test_delete_exception(self):
        ns = NetworkNamespace('')
        with self.assertRaises(subprocess.CalledProcessError) as context:
            ns.delete()

if __name__ == '__main__':
    unittest.main()
