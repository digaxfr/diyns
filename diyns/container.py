"""
Stub.
"""

import subprocess

from . import config

class Container:
    """
    For rootfs, overlays are not used because there are use case where
    overlays are not compatible.

    Creating rootfs is also outside the scope of this tool for now.
    """

    _unshare_cmd = '/usr/bin/unshare'

    def __init__(self, name, netns):
        self.cpu_shares = ""
        self.memory = ""
        self.name = name
        self.netns = netns
        self.ports = []
        self.rootfs = f'{config.container_dir}/{name}/rootfs'

    def create(self):
        # Need to check if the container is running first

        # Launch the container sleeper process
        try:
            popen = subprocess.Popen([Container._unshare_cmd,
                f'--root={self.rootfs}',
                f'--net=/var/run/netns/{self.netns}',
                '--pid',
                '--mount-proc',
                '--fork',
                '--cgroup',
                '--uts',
                '--ipc',
                '--mount',
                '/bin/bash',
                '-c',
                'sleep infinity'
                ],
                shell=False,
                stdin=None,
                stdout=None,
                stderr=None,
                )

            print(popen.pid)
            #popen.kill()

        except ResourceWarning as e:
            print(e)

        except subprocess.CalledProcessError as e:
            stderr = e.stderr.decode('utf-8')
            print(f'An error occurred while creating the container: {stderr}')
            raise

        # Store the child PID

    # Delete
