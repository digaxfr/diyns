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
        self.rootfs = f'{config.CONTAINER_DIR}/{name}/rootfs'

    def up(self):
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

            # Save the PID of unshare
            with open(f'{config.CONTAINER_DIR}/{self.name}/unshare.pid', 'w') as file:
                file.write(str(popen.pid))

            # Get and save the child PID (sleeper)
            sleeper_pid = self._get_child_pid(str(popen.pid))
            with open(f'{config.CONTAINER_DIR}/{self.name}/sleeper.pid', 'w') as file:
                file.write(str(sleeper_pid))

        except subprocess.CalledProcessError as e:
            stderr = e.stderr.decode('utf-8')
            print(f'An error occurred while creating the container: {stderr}')
            raise


    def _get_child_pid(self, ppid):
        try:
            popen = subprocess.Popen([
                'ps',
                '--ppid',
                ppid,
                '-o',
                'pid='
                ],
                shell=False,
                stdin=None,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
                )
            rc = popen.wait()

            if rc != 0:
                print("An error occurred while getting the child pid")
                raise

            child_pid = str(popen.stdout.read().decode('utf-8')).strip(' ')
            return child_pid

        except subprocess.CalledProcessError as e:
            stderr = e.stderr.decode('utf-8')
            print(f'An error occurred while getting the child PID: {stderr}')
            raise
