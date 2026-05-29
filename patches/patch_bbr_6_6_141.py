from pathlib import Path

p = Path("/root/build-linux-6.6.141-bbrgain/linux-6.6.141/net/ipv4/tcp_bbr.c")
s = p.read_text()

replacements = {
    "static const u32 bbr_min_rtt_win_sec = 10;":
        "static const u32 bbr_min_rtt_win_sec = 6;",
    "static const int bbr_high_gain  = BBR_UNIT * 2885 / 1000 + 1;":
        "static const int bbr_high_gain  = BBR_UNIT * 34 / 10;",
    "static const int bbr_cwnd_gain  = BBR_UNIT * 2;":
        "static const int bbr_startup_cwnd_gain = BBR_UNIT * 34 / 10;\n"
        "static const int bbr_cwnd_gain  = BBR_UNIT * 34 / 10;",
    "BBR_UNIT * 5 / 4,\t/* probe for more available bw */\n"
    "\tBBR_UNIT * 3 / 4,\t/* drain queue and/or yield bw to other flows */\n"
    "\tBBR_UNIT, BBR_UNIT, BBR_UNIT,\t/* cruise at 1.0*bw to utilize pipe, */\n"
    "\tBBR_UNIT, BBR_UNIT, BBR_UNIT\t/* without creating excess queue... */":
        "BBR_UNIT * 16 / 10,\t/* probe for more available bw */\n"
        "\tBBR_UNIT * 10 / 16,\t/* drain queue and/or yield bw to other flows */\n"
        "\tBBR_UNIT * 17 / 10, BBR_UNIT * 17 / 10, BBR_UNIT * 17 / 10,\t/* cruise aggressively, */\n"
        "\tBBR_UNIT * 17 / 10, BBR_UNIT * 17 / 10, BBR_UNIT * 17 / 10\t/* without dropping below target rate... */",
    "static const u32 bbr_lt_loss_thresh = 50;":
        "static const u32 bbr_lt_loss_thresh = BBR_UNIT * 55 / 100;",
    "bbr->cwnd_gain\t = bbr_high_gain;":
        "bbr->cwnd_gain\t = bbr_startup_cwnd_gain;",
    "bbr->cwnd_gain\t = bbr_high_gain;\t/* keep cwnd */":
        "bbr->cwnd_gain\t = bbr_startup_cwnd_gain;\t/* keep cwnd */",
}

for old, new in replacements.items():
    if old not in s and new in s:
        continue
    if old not in s:
        raise SystemExit(f"missing expected text: {old!r}")
    s = s.replace(old, new, 1)

p.write_text(s)
