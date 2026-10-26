# CIR-002: Authenticate with a read-only OAuth token

## Intent
Keep the screen updating while every personal machine is off, without giving
TRMNL (or any other service) a credential that can change or read everything in
the AppSignal account.

## Behavior
- GIVEN the plugin is connected with OAuth
- WHEN TRMNL refreshes it
- THEN the screen shows the app's open incidents and monitors, as before

- GIVEN TRMNL's stored token leaks
- WHEN someone uses it
- THEN they can only read data in the approved organization, and revoking that
  one token in AppSignal stops them without touching any other credential

- GIVEN the plugin is not connected yet
- WHEN TRMNL refreshes it
- THEN the screen says AppSignal did not answer and shows AppSignal's message

## Constraints
- TRMNL sends one request per polling address per refresh, with the same body
  for every address.
- AppSignal's GraphQL API is the only interface that returns structured data
  for incidents and uptime alerts in one request.
- AppSignal registers OAuth clients without approval but accepts one callback
  address per client, and returns an existing client when the callbacks match
  one it already has.
- Uploads do not set the OAuth client ID on TRMNL; it is pasted into the
  plugin's OAuth settings once. Recipe installs use the publisher's client
  when the publisher ticks "Share OAuth credentials with recipe installers?".
  TRMNL leaves client credentials, polling headers, and the polling body out
  of exports.
- AppSignal rate-limits per user and IP address, not per OAuth client, and its
  client registration takes no contact address.

## Decisions
- OAuth with the `app:read` scope replaces the personal API token, which could
  read and change every app the user can see.
- Rejected: pushing data to a TRMNL webhook from a scheduled job. With the
  laptop off the job must run on another service (GitHub Actions, a small
  host), which then holds a credential instead of TRMNL, so it moves the risk
  without reducing it.
- Rejected: polling AppSignal's MCP server with an MCP token. It allows the
  narrowest token (one app, chosen read-only tools) and answers a stand-alone
  request, but its tools return Markdown written for an AI assistant, TRMNL can
  call only one tool per refresh, and uptime status needs a metrics query and
  arithmetic.
- Rejected: AppSignal's outgoing webhook notifier pointed at TRMNL. It needs no
  credential, but sends events, so the screen could not show what is currently
  open.
- Every request sends a `User-Agent` naming the GitHub repository, so AppSignal
  can find the maintainer of the shared client.
- Two OAuth clients (TRMNL and local preview) because AppSignal keeps only one
  callback per client.
- `bin/push` restores `src/settings.yml` after each push, because `trmnlp push`
  replaces it with an export that drops the polling headers and body.

## Date
2026-10-24

Supersedes: CIR-001
