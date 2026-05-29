# X Kernel: Linux 6.6.141 BBR Gain 340

This repository contains a custom Linux kernel build based on Linux 6.6.141 LTS.

The kernel keeps the upstream TCP congestion control name `bbr`, but changes the
BBR constants in `net/ipv4/tcp_bbr.c` for a more aggressive sender profile.

## Release

- Kernel release: `6.6.141-bbrgain340`
- Base kernel: Linux `6.6.141`
- Architecture: `amd64`
- Target systems: Debian/Ubuntu x86_64 VPS/KVM environments
- Build host used: `38.54.82.215`

## BBR Parameters

| Parameter | Value |
| --- | --- |
| BBRStartupPacingGain | `3.4` |
| BBRStartupCwndGain | `3.4` |
| BBRPacingGain | `1.7` |
| BBRCwndGain | `3.4` |
| BBRLossThresh | `0.55` |
| BBRProbeBWGain | `1.6` |
| BBRProbeRTTGain | `1.0` |
| BBRMinRttFilterLen | `6` seconds |

## Files

- `artifacts/deb/`: installable Debian packages.
- `patches/bbrgain340-tcp_bbr.patch`: unified diff against upstream Linux 6.6.141.
- `patches/patch_bbr_6_6_141.py`: patch helper used during build.
- `src/net/ipv4/tcp_bbr.c`: patched BBR source file.
- `config/kernel-config-6.6.141-bbrgain340`: kernel `.config` used for the build.
- `scripts/build_6_6_141_bbrgain.sh`: build script used on the build host.
- `sysctl/9999-bbrgain340.conf`: runtime BBR/fq sysctl settings.
- `SHA256SUMS`: checksums for release artifacts and source materials.
- `build.log`: build log from the successful package build.

## Install

See `INSTALL.md`.

## Notes

This is an aggressive BBR tuning intended for VPS proxy/upload workloads where
fast startup and pushing traffic out quickly matter more than fairness.
