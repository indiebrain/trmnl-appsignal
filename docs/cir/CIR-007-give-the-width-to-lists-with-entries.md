# CIR-007: Give the full view's width and height to the lists with entries

## Intent
Show as many open incidents and failing monitors as the screen holds, and
keep their names whole, while the counts stay readable from across a room.

## Behavior
- GIVEN some lists have entries and others are empty
- WHEN the full view is drawn on a TRMNL X in landscape
- THEN each empty column shows only its count and narrows to fit it, and the
  columns with entries share the rest of the width

- GIVEN every list has entries, or none has
- WHEN the full view is drawn on a TRMNL X in landscape
- THEN the three columns are equal

- GIVEN any device or orientation
- WHEN the full view is drawn
- THEN the counts sit at the top and the lists run to the bottom of the screen

- GIVEN the half and quadrant views
- WHEN they are drawn
- THEN they SHOULD NOT change

## Constraints
- On the TRMNL X in landscape each count heads its own list, so a column can
  change width without its count moving out of line with its list. On the
  original TRMNL and in portrait some lists are hidden, so the counts stay in
  a row of their own there.
- The framework's "and N more" counter fills a list only to the bottom of its
  `.columns` box, so that box stretches to the bottom of the screen.
- The framework has no class that sizes a column to its content on one device
  and orientation, so the view carries a small style rule for it.

## Decisions
- Rejected: fixed width shares (one part for an empty column, two for a list).
  A quarter of the screen is too narrow for a monitor count such as "0/6" at
  the size the counts use.
- Rejected: smaller counts to free height for longer lists. The counts are what
  a glance from across the room reads.

## Date
2026-10-27
