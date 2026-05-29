#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/ericyiu9819/X/main/artifacts/deb}"
WORKDIR="${WORKDIR:-/root/bbrgain340}"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

wget -O linux-image-6.6.141-bbrgain340_1_amd64.deb \
  "$BASE_URL/linux-image-6.6.141-bbrgain340_1_amd64.deb"
wget -O linux-headers-6.6.141-bbrgain340_1_amd64.deb \
  "$BASE_URL/linux-headers-6.6.141-bbrgain340_1_amd64.deb"

dpkg -i ./linux-image-6.6.141-bbrgain340_1_amd64.deb ./linux-headers-6.6.141-bbrgain340_1_amd64.deb
update-grub

cat >/etc/sysctl.d/9999-bbrgain340.conf <<'CONF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
CONF

sysctl -p /etc/sysctl.d/9999-bbrgain340.conf

echo "Installed 6.6.141-bbrgain340. Reboot and verify with: uname -r"
