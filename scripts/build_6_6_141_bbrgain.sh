#!/usr/bin/env bash
set -euo pipefail

cd /root/build-linux-6.6.141-bbrgain/linux-6.6.141
cp "/boot/config-$(uname -r)" .config

scripts/config --set-str LOCALVERSION "-bbrgain340"
scripts/config --disable LOCALVERSION_AUTO
scripts/config --set-str SYSTEM_TRUSTED_KEYS "" || true
scripts/config --set-str SYSTEM_REVOCATION_KEYS "" || true
scripts/config --enable TCP_CONG_BBR
scripts/config --enable NET_SCH_FQ
scripts/config --disable DEBUG_INFO || true
scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT || true
scripts/config --disable DEBUG_INFO_BTF || true
scripts/config --disable MODULE_SIG || true

make olddefconfig
make -j1 bindeb-pkg KDEB_PKGVERSION=1
