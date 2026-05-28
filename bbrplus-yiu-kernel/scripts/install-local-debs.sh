#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
apt-get install -y ./linux-image-6.13.7-bbrplus-yiu+_1_amd64.deb ./linux-headers-6.13.7-bbrplus-yiu+_1_amd64.deb
update-grub
cat >/etc/sysctl.d/9999-bbrplus-yiu.conf <<'SYSCTL'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbrplus_yiu
SYSCTL
sysctl --system
