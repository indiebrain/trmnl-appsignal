# AppSignal for TRMNL

A private TRMNL plugin that shows an AppSignal app's open incidents and uptime
monitors. Built for the TRMNL X (1872 by 1404, 16 grays) and still readable on
the original TRMNL.

| View | Shows |
|------|-------|
| Full | Open error count, slow action count, monitors down, latest errors, latest performance issues |
| Half (either way) | Open error count, monitors down, latest errors |
| Quadrant | Open error count with a one-line summary |

TRMNL polls AppSignal's GraphQL API directly every 15 minutes. No server of
your own is needed.

## Setup

1. In AppSignal, create a personal API token (Personal settings, API tokens).
2. Find the app ID in the app's settings page, or in the address bar
   (`appsignal.com/<organization>/sites/<app ID>`).
3. Install the TRMNL preview tool: `gem install trmnl_preview` (Ruby 4.0).
4. Push the plugin to your TRMNL account:

   ```sh
   trmnlp login
   trmnlp push
   ```

5. In TRMNL, open the new "AppSignal" private plugin, fill in the token and app
   ID, and add it to your playlist.

## Local development

```sh
export APPSIGNAL_API_TOKEN=...   # read by .trmnlp.yml
export APPSIGNAL_APP_ID=...
trmnlp serve                     # live preview at http://localhost:4567
trmnlp lint
```

The tests need Firefox and ImageMagick, so run them in Docker:

```sh
docker run --rm -v "$PWD":/plugin trmnl/trmnlp test
docker run --rm -v "$PWD":/plugin trmnl/trmnlp test --update   # re-record snapshots
```

They render every view against a canned response (`tests/fixtures/`), on both
the original TRMNL (`og_plus`) and the TRMNL X (`v2`), and compare against the
pictures in `tests/snapshots/`.

## Limits

- Counts stop at 100 per incident type and show as "99+" beyond that.
- A monitor counts as down when it has an alert in the `OPEN` state.
- The token travels in the polling address because AppSignal's GraphQL API only
  accepts it there. It is stored in TRMNL as a password field.
