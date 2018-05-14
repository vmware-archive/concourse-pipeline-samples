#!/usr/bin/env bash
set -x

echo "Running find command"
#find .
#sleep 2
cat /etc/lsb-release
apt-get -y install curl
curl 192.168.99.100:5000/v2/ubuntu/manifests/latest
