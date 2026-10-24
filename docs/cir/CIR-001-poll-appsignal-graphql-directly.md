# CIR-001: Poll AppSignal's GraphQL API directly from TRMNL

Status: Superseded by CIR-002 (the plugin now signs in with read-only OAuth
instead of a personal API token).

## Intent
Show an AppSignal app's health on a TRMNL X without running any service of our
own.

## Behavior
- GIVEN a valid personal API token and app ID
- WHEN TRMNL refreshes the plugin
- THEN the screen shows open error and performance incident counts, monitors
  down, and the most recent open incidents

- GIVEN AppSignal rejects the request (bad token, unknown app)
- WHEN TRMNL refreshes the plugin
- THEN the screen says AppSignal did not answer and shows AppSignal's message

- GIVEN incident text containing markup characters (for example `#<TCPSocket>`)
- WHEN it is drawn
- THEN it appears as literal text and does not break the layout

## Constraints
- TRMNL polling can send a POST with a JSON body and interpolate form fields,
  so one GraphQL request fits without a proxy.
- AppSignal's GraphQL API takes the token only as a `token` query parameter.

## Decisions
- One GraphQL request with aliases instead of the REST API: GraphQL returns
  incidents, uptime monitors and their alerts in one round trip, which keeps
  TRMNL to a single polling address.
- Counts come from a second, `number`-only list capped at 100 instead of a total
  field, because the schema's paginated totals were not confirmed. "99+" covers
  the cap.
- Rejected: a webhook fed by a small worker. It would allow richer data but
  adds a service to host and secure for no visible gain on the screen.
- Relative times ("4m ago") instead of clock times, so the display needs no
  time zone handling.

## Date
2026-10-23
