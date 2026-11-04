#!/bin/sh

echo "=== Yocto training image ==="
uname -a

if [ -r /etc/os-release ]; then
    cat /etc/os-release
fi

if [ -r /proc/config.gz ]; then
    echo "--- kernel configuration ---"
    echo "/proc/config.gz is available (CONFIG_IKCONFIG_PROC=y)"
fi
