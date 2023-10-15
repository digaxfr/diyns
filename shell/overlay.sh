#!/bin/bash

basedir='/home/darrenchin/Downloads'

mount -t overlay overlay -o lowerdir=${basedir}/bookworm-lower,upperdir=${basedir}/container1/upper,workdir=${basedir}/container1/work ${basedir}/container1/merged

# IF we are doing native, mount --bind /dir /dir
# also mount -t devtmpfs devtmpfs /path/to/native/dev
