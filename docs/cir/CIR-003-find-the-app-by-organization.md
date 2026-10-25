# CIR-003: Find the app by organization name, and lay out for portrait

Status: Partly superseded by CIR-005. Picking an app when connecting does not
limit the token to that app; the plugin shows every app, or the one named in
its App setting.

## Intent
Make installation simple enough to share the plugin as a TRMNL recipe: an
installer connects AppSignal and types one short word they can see in their
address bar, with no 24-character app ID to dig up. Meet TRMNL's recipe
publishing checklist, which includes the TRMNL X in portrait.

## Behavior
- GIVEN a connected plugin and the organization name from the address bar
- WHEN TRMNL refreshes it
- THEN the screen shows the first app in that organization that the token can
  read

- GIVEN a wrong organization name
- WHEN TRMNL refreshes it
- THEN the screen shows AppSignal's "Object not found." and suggests checking
  the name or connecting again

- GIVEN the organization name `demo`, in any case or with spaces around it
- WHEN TRMNL refreshes it
- THEN the screen shows built-in example data, whatever AppSignal answers

- GIVEN a TRMNL X in portrait
- WHEN any view is drawn
- THEN nothing is cut off or runs past the edge; the full view shows the error
  list only, with all three counts still at the top

- GIVEN a long Ruby class or action name
- WHEN it does not fit on one line
- THEN it breaks after `::` or `#` and ends with an ellipsis

- GIVEN a TRMNL in landscape
- WHEN any view is drawn
- THEN the layout SHOULD NOT change, apart from long names now ending in an
  ellipsis

## Constraints
- The `app:read` token is refused on AppSignal's `viewer` field ("Your OAuth
  token does not have the required scope"), so the plugin cannot list the
  user's organizations or apps on its own.
- `organization(slug:)` requires the slug, and AppSignal's token response
  carries no organization or app.
- AppSignal answers a blank or wrong organization name with "Object not
  found." and an expired token with a 401 "Request could not be
  authenticated.", so the error screen passes the message through.
- The preview tool's tests do not pass the device orientation to the
  templates, so portrait handling has to use the framework's `portrait:`
  classes, which the real device and the tests both apply.

## Decisions
- Organization name in place of the app ID. AppSignal's approval screen asks
  which app to allow, so the organization list should hold only that app. This
  is untested with an organization that has several apps; until confirmed, the
  plugin shows the first app.
- Rejected: discovering the app with no setting at all. Needs `viewer`, which
  the read-only scope does not grant, and asking for `app:write` to get it would
  undo CIR-002.
- Portrait full view hides the performance list (`portrait:hidden`) instead of
  stacking the two lists. The framework's `.column` has zero width outside a
  row, and no portrait full-width class exists, so stacking needed a separate
  Liquid layout keyed on an orientation variable that the tests do not set.
- Long names get a zero-width space after `::` and `#`. A one-line clamp cannot
  shorten a single unbroken word, so these names ran past the column edge. The
  `#` replacement runs first so it does not hit the `#` inside `&#8203;`.
- Demo mode keyed on the organization name. TRMNL draws the marketplace
  picture from the owner's own plugin, which would publish the owner's app and
  incidents. Rejected: a separate demo setting, which adds a field every
  installer has to read past. The example data lives in `shared.liquid` with
  times as offsets from now, so it never looks stale.

## Date
2026-10-24
