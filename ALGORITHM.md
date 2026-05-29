# Algorithm Changes

The patch modifies upstream Linux 6.6.141 `net/ipv4/tcp_bbr.c`.

BBR uses fixed-point gain values with:

```c
#define BBR_SCALE 8
#define BBR_UNIT (1 << BBR_SCALE)
```

So:

- `3.4` is represented as `BBR_UNIT * 34 / 10`.
- `1.7` is represented as `BBR_UNIT * 17 / 10`.
- `1.6` is represented as `BBR_UNIT * 16 / 10`.
- `0.55` is represented as `BBR_UNIT * 55 / 100`.

## Main Changes

- Min RTT filter window changed from `10` seconds to `6` seconds.
- STARTUP pacing gain changed from upstream `2.885` to `3.4`.
- STARTUP cwnd gain changed to `3.4`.
- steady-state cwnd gain changed from `2.0` to `3.4`.
- PROBE_BW first probe gain changed from `1.25` to `1.6`.
- PROBE_BW cruise phases changed from `1.0` to `1.7`.
- long-term loss threshold changed from `50` to `0.55` in BBR fixed-point form.
- PROBE_RTT gain remains `1.0`.

## Behavior

This is a high-pressure sender profile. It is designed to start faster, keep a
larger cwnd, tolerate more random loss, and continue pacing above the measured
bandwidth estimate during the PROBE_BW cycle.

It is best suited for single-user VPS proxy/upload workloads. It may increase
queueing delay and reduce fairness on narrow or already-congested links.
