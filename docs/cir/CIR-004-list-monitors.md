# CIR-004: List uptime and check-in monitors with their status

## Intent
Show which monitors are failing, not only how many, so a glance at the screen
says what to look at. Check-in monitors (cron jobs and heartbeats) count
alongside uptime monitors, because a missed backup matters as much as a site
that is down.

## Behavior
- GIVEN an app with uptime and check-in monitors
- WHEN the full view is drawn on a TRMNL X in landscape
- THEN a third column lists every monitor with its status, down monitors first

- GIVEN an uptime monitor with an `OPEN` alert, or a check-in monitor whose
  latest run was `MISSED` or `LATE`
- WHEN any view is drawn
- THEN it counts toward "Monitors down", out of all monitors of both kinds

- GIVEN the original TRMNL, or a TRMNL X in portrait
- WHEN the full view is drawn
- THEN the monitor column is hidden, and only the count shows

## Constraints
- AppSignal's GraphQL API exposes check-in monitors as
  `app.checkIns.triggers`, with `lastState` (`NEW`, `STARTED`, `FINISHED`,
  `MISSED`, `LATE`, `UNEXPECTED`) for the latest run.
- The original TRMNL's 800-pixel width cannot fit three columns: text runs
  past the column edges.
- The framework's `lg:visible` sets `display: block`, which drops the
  column's flex layout; `lg:flex` keeps it.

## Decisions
- Down monitors are listed first. The column ends with an "and N more"
  counter when it overflows, so this order hides only healthy monitors.
- `UNEXPECTED` (a run outside the schedule) does not count as down: it means
  the job ran, at an odd time.
- Detail rows under each list item wrap whole labels to a second line. At a
  third of the screen, squeezing them split "4m ago" over two lines.
- Rejected: replacing the performance column with monitors. It keeps two wide
  columns, but drops slow actions from the screen that has room for them.

## Date
2026-10-25
