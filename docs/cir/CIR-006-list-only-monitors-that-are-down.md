# CIR-006: List only the monitors that are down

## Intent
Make every row in the monitor column something to act on. The "Monitors down"
count already says how many monitors are healthy.

## Behavior
- GIVEN monitors, some of them down
- WHEN the full view is drawn on a TRMNL X in landscape
- THEN the monitor column lists only the monitors that are down

- GIVEN monitors, none of them down
- WHEN the full view is drawn on a TRMNL X in landscape
- THEN the column says "All N monitors up."

- GIVEN no monitors at all
- WHEN the full view is drawn
- THEN the column says "No monitors."

- GIVEN any monitors
- WHEN any view is drawn
- THEN the "Monitors down" count still counts monitors of both kinds, healthy
  or not

## Constraints
- The column is a third of the screen and ends with an "and N more" counter, so
  healthy rows took the space that failures need.

## Decisions
- Rejected: a setting to choose between every monitor and failed ones. It adds
  a field every installer has to read, and test pictures for both modes, for
  rows that repeat what the count says.
- Accepted loss: the last-run time of healthy check-in monitors. A check-in
  that stops running turns `MISSED` or `LATE` and joins the list.

## Date
2026-10-26

Supersedes: CIR-004 (in part)
