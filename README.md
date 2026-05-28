# BBR Plus AI Kernel

Build date: 2026-05-28, Asia/Shanghai

This repository records the custom Linux kernel compiled today with a new TCP congestion control algorithm named `bbrplus_ai`.

## Kernel

- Base tree: Google BBR v3 tree, Linux 6.13.7
- Base commit suffix: `g90210de4b779`
- Kernel release: `6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty`
- Architecture: `x86_64` / `amd64`
- Build host OS: Ubuntu 24.04.2 LTS
- Build host: `38.54.82.215`
- Build time shown by kernel: `Thu May 28 11:08:05 CST 2026`

## New Congestion Control

Algorithm name:

```text
bbrplus_ai
```

Available after boot:

```text
reno bbr bbrplus_ai cubic
```

Enabled runtime configuration:

```conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbrplus_ai
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_limit_output_bytes = 131072
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_mtu_probing = 1
```

## What Was Changed

A new independent TCP congestion control module was added instead of replacing existing `bbr` or `cubic`:

```text
net/ipv4/tcp_bbrplus_ai.c
```

Kernel build integration:

```text
CONFIG_TCP_CONG_BBRPLUS_AI=y
obj-$(CONFIG_TCP_CONG_BBRPLUS_AI) += tcp_bbrplus_ai.o
```

Kconfig also gained:

```text
config TCP_CONG_BBRPLUS_AI
config DEFAULT_BBRPLUS_AI
default "bbrplus_ai" if DEFAULT_BBRPLUS_AI
```

## Adaptive Logic

`bbrplus_ai` is based on the BBR Plus / BBR v1 style state machine, but adds a lightweight in-kernel adaptive controller. It measures RTT inflation:

```c
rtt_ratio = srtt_us / min_rtt_us
```

Then it dynamically changes `pacing_gain` and `cwnd_gain`.

Behavior summary:

```text
Clean RTT:
    keep normal BBR Plus-style probing
    probe high gain can remain around 1.25
    cwnd gain remains around 2.0

RTT mildly inflated, >= 1.15x min_rtt:
    reduce high probing to around 1.10
    reduce cwnd gain to around 1.75

RTT inflated, >= 1.30x min_rtt:
    avoid aggressive probing
    use around 0.90 / 1.00 pacing behavior
    reduce cwnd gain to around 1.50

RTT heavily inflated, >= 1.50x min_rtt:
    force conservative pacing around 0.75
    reduce cwnd gain to around 1.25

Long-term bandwidth / policer mode:
    use pacing gain 1.00
    reduce cwnd gain to around 1.25
```

The goal is not maximum speed-test burst, but better VPS web browsing and video playback stability by reducing queue buildup and RTT spikes.

## Build Artifacts

Generated Debian packages:

```text
linux-image-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb
linux-headers-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb
linux-libc-dev_1_amd64.deb
```

File sizes:

```text
12M   linux-image-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb
8.8M  linux-headers-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb
1.4M  linux-libc-dev_1_amd64.deb
```

SHA256:

```text
c6f6c285dcaabea6c74c4ce9104c1f24306af6aa91488c025857b24d753833b3  linux-image-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb
f771ac4bf1aeab9027ece24ab19fc263047d34879cbcc568c072e3ed9c419cc5  linux-headers-6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty_1_amd64.deb
9d0bb472282cd22696db71419b57b17592d9cba8918621aaa4607c77020f050a  linux-libc-dev_1_amd64.deb
```

## Verified VPS Installs

### 38.54.82.215

```text
OS: Ubuntu 24.04.2 LTS
Kernel: 6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty
Available congestion control: reno bbr bbrplus_ai cubic
Active congestion control: bbrplus_ai
Default qdisc: fq
```

### 203.88.127.40

```text
OS: Debian 12 bookworm
Kernel: 6.13.7-bbrv3-g90210-bbrplus-ai-g90210de4b779-dirty
Available congestion control: reno bbr bbrplus_ai cubic
Active congestion control: bbrplus_ai
Default qdisc: fq
```

## Notes

- Existing `bbr` and `cubic` remain available as fallback algorithms.
- This is an experimental custom kernel.
- The algorithm is a lightweight adaptive controller inside the kernel, not a neural-network or large-model AI runtime.
- For web/video VPS traffic, the tuning intentionally favors lower RTT spikes and more stable delivery over peak benchmark numbers.
