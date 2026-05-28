# Install BBR Plus AI Kernel on Another VPS

Target OS tested:

```text
Ubuntu 24.04 x86_64
Debian 12 x86_64
```

Kernel package:

```text
6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty
```

## 1. Download Packages from This Repository

On the new VPS:

```bash
mkdir -p /root/bbrplus-ai-kernel
cd /root/bbrplus-ai-kernel

base_url="https://raw.githubusercontent.com/ericyiu9819/X/main/artifacts/deb"

curl -fL -O "$base_url/linux-image-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb"
curl -fL -O "$base_url/linux-headers-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb"
curl -fL -O "$base_url/linux-libc-dev_1_amd64.deb"
curl -fL -O "$base_url/SHA256SUMS"
```

## 2. Verify SHA256

```bash
sha256sum -c SHA256SUMS
```

Expected:

```text
linux-image-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb: OK
linux-headers-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb: OK
linux-libc-dev_1_amd64.deb: OK
```

SHA256 values:

```text
c6f6c285dcaabea6c74c4ce9104c1f24306af6aa91488c025857b24d753833b3  linux-image-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb
f771ac4bf1aeab9027ece24ab19fc263047d34879cbcc568c072e3ed9c419cc5  linux-headers-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb
9d0bb472282cd22696db71419b57b17592d9cba8918621aaa4607c77020f050a  linux-libc-dev_1_amd64.deb
```

## 3. Install Kernel

```bash
cd /root/bbrplus-ai-kernel

dpkg -i \
  linux-image-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb \
  linux-headers-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb
```

`linux-libc-dev_1_amd64.deb` is optional for normal runtime use.

## 4. Set GRUB Default Kernel

Ubuntu example:

```bash
grub-set-default 'Advanced options for Ubuntu>Ubuntu, with Linux 6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty'
```

Debian example:

```bash
grub-set-default 'Advanced options for Debian GNU/Linux>Debian GNU/Linux, with Linux 6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty'
```

Check menu names if needed:

```bash
grep -n "menuentry '\|submenu '" /boot/grub/grub.cfg | less
```

## 5. Enable bbrplus_ai

Create final-priority sysctl config:

```bash
cat >/etc/sysctl.d/999-bbrplus-ai.conf <<'EOF'
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbrplus_ai
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_limit_output_bytes = 131072
EOF
```

If old configs override it, find them:

```bash
grep -R "tcp_congestion_control\|default_qdisc" -n /etc/sysctl.conf /etc/sysctl.d /usr/lib/sysctl.d 2>/dev/null
```

Then apply:

```bash
sysctl --system
```

## 6. Reboot

```bash
reboot
```

## 7. Verify After Reboot

```bash
uname -r
sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc
sysctl net.ipv4.tcp_notsent_lowat
sysctl net.ipv4.tcp_limit_output_bytes
```

Expected:

```text
6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty
net.ipv4.tcp_available_congestion_control = reno bbr bbrplus_ai cubic
net.ipv4.tcp_congestion_control = bbrplus_ai
net.core.default_qdisc = fq
```

## Rollback

Switch back to normal BBR immediately:

```bash
sysctl -w net.ipv4.tcp_congestion_control=bbr
```

For permanent rollback, set GRUB back to an older known-good kernel and reboot.
