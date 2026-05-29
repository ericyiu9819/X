# Install

Install the image package and, optionally, the headers package:

```bash
cd /root
mkdir -p bbrgain340
cd bbrgain340

wget -O linux-image-6.6.141-bbrgain340_1_amd64.deb \
  https://raw.githubusercontent.com/ericyiu9819/X/main/artifacts/deb/linux-image-6.6.141-bbrgain340_1_amd64.deb

wget -O linux-headers-6.6.141-bbrgain340_1_amd64.deb \
  https://raw.githubusercontent.com/ericyiu9819/X/main/artifacts/deb/linux-headers-6.6.141-bbrgain340_1_amd64.deb

dpkg -i ./linux-image-6.6.141-bbrgain340_1_amd64.deb ./linux-headers-6.6.141-bbrgain340_1_amd64.deb
update-grub
```

For a one-time safe boot into the new kernel on Ubuntu:

```bash
grub-reboot 'Advanced options for Ubuntu>Ubuntu, with Linux 6.6.141-bbrgain340'
reboot
```

For Debian, the menu name may be:

```bash
grub-reboot 'Advanced options for Debian GNU/Linux>Debian GNU/Linux, with Linux 6.6.141-bbrgain340'
reboot
```

After reboot:

```bash
uname -r
sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc
```

Expected:

```text
6.6.141-bbrgain340
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
```

Persist runtime settings:

```bash
cat >/etc/sysctl.d/9999-bbrgain340.conf <<'CONF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
CONF

sysctl -p /etc/sysctl.d/9999-bbrgain340.conf
```

Keep the previous kernel until the new kernel has been validated after reboot.
