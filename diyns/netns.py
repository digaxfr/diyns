"""
Stub.
"""

import json

class NetworkNamespace:
    """
    Stub.
    """

    def __init__(self, name):
        self.name = name

    def __str__(self):
        return json.dumps(self.__dict__, indent=2)

    def create(self):
        """
        Create the network namespace.

        Parameters:
        None

        Returns:
        None
        """

        return True

    def delete(self):
        """
        Delete the network namespace.

        Parameters:
        None

        Returns:
        None
        """

        return True
