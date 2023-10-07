"""
Linux Kernel Network Namespaces
"""

import json
import subprocess
import sys
from os import path
from . import config

class NetworkNamespace:
    """
    NetworkNamespace is a Linux Network namespace.
    """

    _ip_cmd = '/usr/bin/ip'

    def __init__(self, name):
        self.name = name

    def __str__(self):
        return json.dumps(self.__dict__)

    def create(self):
        """
        Create the network namespace.
        """

        if not self.status():
            try:
                cp = subprocess.run([NetworkNamespace._ip_cmd,
                    'netns',
                    'add',
                    self.name],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    check=True)

                if config.debug:
                    print(cp)   # pragma: nocover

            except subprocess.CalledProcessError as e:
                stderr = e.stderr.decode('utf-8')
                print(f'An error occurred while creating the network namespace: {stderr}')
                raise

    def delete(self):
        """
        Delete the network namespace.
        """

        # Future: Handle cases where the netns is still in use.

        if self.status():
            try:
                cp = subprocess.run([NetworkNamespace._ip_cmd,
                    'netns',
                    'delete',
                    self.name],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    check=True)

                if config.debug:
                    print(cp)   # pragma: nocover

            except subprocess.CalledProcessError as e:
                stderr = e.stderr.decode('utf-8')
                print(f'An error occurred while deleting the network namespace: {stderr}')
                raise

    def status(self):
        """
        Check if the network namespace exists or not.

        Returns:
            boolean: True if the network namespace exists.
        """

        return path.exists(f'/run/netns/{self.name}')
