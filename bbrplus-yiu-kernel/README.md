# BBRPlus YIU Kernel

Custom Linux 6.13.7 TCP congestion-control experiment derived from the existing BBR/BBRPlus AI kernel tree.

## Goal

`bbrplus_yiu` is a more aggressive BBRPlus-style congestion-control variant for VPS VPN/video/download workloads. It is intentionally biased toward pushing traffic out faster rather than conservatively draining queues.

## Kernel

- Kernel release: `6.13.7-bbrplus-yiu+`
- Target architecture: `amd64 / x86_64`
- Tested environments:
  - Ubuntu 24.04 KVM VPS
  - Debian 12 KVM VPS
- Default queue discipline: `fq`
- Congestion control: `bbrplus_yiu`

## Main acceleration changes

Compared with the previous `bbrplus_ai` variant, this project adds a new independent congestion-control name, `bbrplus_yiu`, and keeps the old algorithm available.

Core behavior:

- STARTUP gain raised to about `3.9x`.
- PROBE_BW high probe raised to about `1.75x`.
- Congestion window target raised to about `3x BDP`.
- Light loss no longer immediately subtracts the full loss count from cwnd.
- Long-term policer detection tolerates more loss before backing off.

This is a pure aggressive variant. It may improve burst/download/video throughput, but can also increase queueing, packet loss, upload instability, or disconnect risk on poor paths.

## Repository contents

- `src/net/ipv4/tcp_bbrplus_yiu.c` - new congestion-control implementation.
- `src/net/ipv4/Kconfig` - TCP congestion-control menu with `BBRPLUS_YIU` entries.
- `src/net/ipv4/Makefile` - build wiring for `tcp_bbrplus_yiu.o`.
- `kernel-config-6.13.7-bbrplus-yiu+` - kernel config used for the build.
- `patches/bbrplus-yiu.patch` - source diff against the working kernel tree.
- `artifacts/SHA256SUMS` - checksums for the generated `.deb` packages.
- `scripts/install-local-debs.sh` - helper for installing local generated packages.

## Runtime commands

Enable the algorithm immediately:

```bash
sysctl -w net.core.default_qdisc=fq
sysctl -w net.ipv4.tcp_congestion_control=bbrplus_yiu
```

Persist it:

```bash
cat >/etc/sysctl.d/9999-bbrplus-yiu.conf <<'SYSCTL'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbrplus_yiu
SYSCTL
sysctl --system
```

Verify:

```bash
uname -r
sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc
```

## Build notes

The original build used the Linux 6.13.7 BBRv3/BBRPlus AI working tree at:

```text
/root/build-bbrv3-6.13.7/bbr
```

Final packages generated on the build VPS:

```text
linux-image-6.13.7-bbrplus-yiu+_1_amd64.deb
linux-headers-6.13.7-bbrplus-yiu+_1_amd64.deb
```

Use `artifacts/SHA256SUMS` to verify package integrity if you copy the `.deb` files from the build host.

## Safety

Do not remove the previous working kernel until the machine has successfully rebooted into `6.13.7-bbrplus-yiu+`, SSH works, and `bbrplus_yiu` appears in `tcp_available_congestion_control`.
