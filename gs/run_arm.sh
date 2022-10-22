#!/bin/bash

# Download image via https://github.com/wtdcode/DebianOnQEMU/releases

cd ~/Downloads

qemu-system-arm -m 2048 -M virt -cpu cortex-a15 -smp cpus=4,maxcpus=4 \
-kernel vmlinuz-5.10.0-16-armmp \
-initrd initrd.img-5.10.0-16-armmp \
-append "root=/dev/sda console=ttyS0" \
-hda ./debian-bullseye-armhf-armmp.qcow2 \
-nographic