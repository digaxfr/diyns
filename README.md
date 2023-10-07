# Do-it-Yourself Namespaces

This project serves multiple purposes:
* Learn to bring up a container from scratch using standard binaries (e.g. `unshare`).
* Get better at writing Python.
  * The original version of this project is written in Bash. Although it does its job, the reality
  is I would like to get more hands on with Python (or really any other language).
* At some point, I would like to transition from simple shell calls into making syscalls.

## Future

* Refactor all subprocess calls. Can I build a wrapper that works for many use cases?
* Unit tests

## Notes

### Container

* Name
* List of Port/veth
* rootfs
* cpushares
* Memory

* Namespaces ?
  * As of now, the namespace is the container

## Network Namespace

* Name

### Port or veth

* Name

* Peer-A Name ?
* Peer-A IPv6
* Peer-A CIDR
* Peer-A netns

* Peer-B Name ?
* Peer-B IPv6
* Peer-B CIDR
* Peer-B netns

### Bridge

* Name
* netns
