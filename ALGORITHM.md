# bbrplus_ai Algorithm

`bbrplus_ai` is a lightweight in-kernel adaptive TCP congestion control algorithm.

It is not a neural-network model. The word `AI` here means automatic adaptive tuning inside the kernel.

## Base Logic

The algorithm keeps the BBR Plus / BBR v1 model:

```text
bottleneck_bandwidth = max recent delivery rate
min_rtt = minimum RTT over the sampling window
BDP = bottleneck_bandwidth * min_rtt
pacing_rate = bottleneck_bandwidth * pacing_gain
cwnd = BDP * cwnd_gain
```

State machine:

```text
STARTUP
DRAIN
PROBE_BW
PROBE_RTT
```

## New Adaptive Signal

`bbrplus_ai` adds RTT inflation awareness:

```text
rtt_ratio = smoothed_rtt / min_rtt
```

In kernel code:

```c
static u32 bbrplus_ai_rtt_ratio(const struct sock *sk, const struct bbr *bbr)
{
    const struct tcp_sock *tp = tcp_sk(sk);
    u32 srtt_us = tp->srtt_us >> 3;

    if (!bbr->min_rtt_us || !srtt_us)
        return BBR_UNIT;

    return min_t(u32, (u64)srtt_us * BBR_UNIT / bbr->min_rtt_us,
                 BBR_UNIT * 4);
}
```

## Adaptive Gain Rules

### STARTUP

Original BBR Plus uses very aggressive startup gain.

`bbrplus_ai` keeps aggressive startup only when RTT is still clean:

```text
if rtt_ratio > 1.30:
    startup pacing_gain = 2.30
else:
    startup pacing_gain = 2.885
```

Purpose: avoid exploding queues during startup on VPS routes.

### DRAIN

```text
pacing_gain = bbr_drain_gain
```

If RTT is heavily inflated:

```text
if rtt_ratio > 1.50:
    cwnd_gain = 1.25
else:
    cwnd_gain = high_gain
```

Purpose: drain queue more effectively when latency is already high.

### PROBE_BW

This is the main adaptive part.

```text
if lt_use_bw:
    pacing_gain = 1.00
    cwnd_gain = 1.25

else if rtt_ratio >= 1.50:
    pacing_gain = 0.75
    cwnd_gain = 1.25

else if rtt_ratio >= 1.30:
    high probe phase uses 0.90, other phases use 1.00
    cwnd_gain = 1.50

else if rtt_ratio >= 1.15:
    high probe phase uses 1.10
    cwnd_gain = 1.75

else:
    use normal BBR Plus / BBR v1 probe cycle
    cwnd_gain = 2.00
```

## Behavior Summary

```text
Clean link:
    behaves close to BBR Plus / BBR v1
    keeps bandwidth probing ability

Mild queue buildup:
    reduces probe aggressiveness
    reduces inflight target

Heavy queue buildup:
    stops high-gain probing
    actively drains by pacing below estimated bandwidth

Long-term bandwidth / suspected policer:
    avoids repeated aggressive probing
    keeps cwnd lower
```

## Why This Helps Web and Video

Web browsing and video playback often suffer when a VPS route builds excessive queue delay:

```text
large transfer fills queue
small web requests wait behind queue
ACKs return late
video buffer becomes unstable
```

`bbrplus_ai` tries to keep throughput high while reducing RTT spikes:

```text
only probe aggressively when RTT is clean
back off when extra sending only creates queue delay
keep fq pacing enabled
limit excessive unsent/output buffering with sysctl
```

## Tradeoff

This algorithm may show slightly lower peak speed-test numbers than a very aggressive BBR Plus build.

Expected benefit:

```text
better web page opening behavior
smoother video playback
lower RTT spikes during sustained transfer
less repeated collision with VPS/ISP policers
```
