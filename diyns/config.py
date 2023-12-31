"""
Config.
"""

import os

# Set the debug flag.
debug = os.environ.get('DIYNS_DEBUG') == '1'

# Directory for containers
CONTAINER_DIR = '/var/lib/lab-containers'
