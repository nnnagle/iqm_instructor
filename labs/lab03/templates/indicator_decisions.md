# Indicator decisions — Module 2

For **each** candidate indicator, record whether you keep or drop it for the
rating, and **why**, citing what you found in the exploratory analysis
(distribution, redundancy with another indicator, geographic behavior, and
fitness for measuring primary-care *need*). "It correlates with need" is not
enough on its own.

| Indicator        | Keep / Drop | Reason (evidence from the EDA) |
|------------------|-------------|--------------------------------|
| `poverty_rate`     | keep (example) | Broad measure of economic need; well-behaved distribution; correlated with but not redundant to the others. Example row — replace with your own judgment. |
| `novehicle_rate`   | ___ | ___ |
| `uninsured_pct`    | ___ | ___ |
| `age65_pct`        | ___ | ___ |
| `disability_pct`   | ___ | ___ |
| `dist_nearest_km`  | ___ | ___ (access, not need — you built this; note the centroid-distance limitation) |
| `n_centers_15km`   | ___ | ___ (access; redundant with `dist_nearest_km`?) |

## Notes

- If you dropped an indicator because it is redundant with another, say which
  one and cite the correlation.
- If two indicators mostly measure the same construct, note how you'll avoid
  double-counting it in the rating.
- Flag any indicator you're keeping despite a known weakness, and say why.
