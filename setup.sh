#!/bin/bash
usermod -g 3003 -G 3003,3004 -a _apt
sleep 1
usermod -G 3003 -a root
sleep 1
echo "nameserver 8.8.8.8" | tee /etc/resolv.conf
sleep 1
echo -e "127.0.0.1       localhost kali ubuntu debian" | tee /etc/hosts
sleep 1
usermod -aG aid_inet,aid_sdcard_rw,aid_graphics,aid_everybody,aid_system,root,aid_media_rw $(whoami)
