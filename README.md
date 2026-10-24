# AppSignal for TRMNL

A private TRMNL plugin that shows an AppSignal app's open incidents and uptime
monitors. Built for the TRMNL X (1872 by 1404, 16 grays) and still readable on
the original TRMNL.

| View | Shows |
|------|-------|
| Full | Open error count, slow action count, monitors down, latest errors, latest performance issues |
| Half (either way) | Open error count, monitors down, latest errors |
| Quadrant | Open error count with a one-line summary |

TRMNL polls AppSignal's GraphQL API directly every 15 minutes, so no server of
your own is needed. It signs in with OAuth and asks only for the `app:read`
scope: TRMNL never holds a personal API token, and the token it does hold can
only read, belongs to one organization, and can be revoked on its own.

## Setup

1. Install the TRMNL preview tool: `gem install trmnl_preview` (Ruby 4.0).
2. Create the plugin in your TRMNL account with your TRMNL account API key
   (from trmnl.com/account). The push prints the plugin settings address; the
   number at its end is the plugin ID.

   ```sh
   TRMNL_API_KEY=user_... trmnlp push
   git checkout -- src/settings.yml   # see "Pushing changes" below
   ```

3. In TRMNL, open the plugin, click **Connect with OAuth**, and approve read
   access in AppSignal. If AppSignal offers an app picker, choose only the app
   you want on the screen.
4. Fill in the app ID, which is in the app's settings page or the address bar
   (`appsignal.com/<organization>/sites/<app ID>`), and add the plugin to your
   playlist.

## OAuth clients

AppSignal registers OAuth clients automatically, but accepts one callback
address per client, so there are two:

| Client ID | Callback | Used by |
|-----------|----------|---------|
| `SSxE-b54Nak88428BadY9JQeDS0sck3JGgycXSIL2ho` | `https://trmnl.com/plugin_settings/private_plugin/oauth/redirect` | TRMNL (in `src/settings.yml`) |
| `nUr-tu_3pJcoct2D0XoWZWsGPPNATOdTtjBjEXT6Jrk` | `http://localhost:4567/oauth/callback` | `trmnlp serve` (as `TRMNL_OAUTH_CLIENT_ID`) |

Client IDs are public: they identify the plugin to AppSignal and grant nothing
on their own. To register your own, post to AppSignal's registration endpoint:

```sh
curl -X POST https://appsignal.com/oauth/register \
  -H 'Content-Type: application/json' \
  -d '{"client_name": "TRMNL AppSignal display",
       "redirect_uris": ["https://trmnl.com/plugin_settings/private_plugin/oauth/redirect"],
       "grant_types": ["authorization_code", "refresh_token"],
       "response_types": ["code"],
       "token_endpoint_auth_method": "none",
       "scope": "app:read"}'
```

TRMNL keeps the client ID from the plugin's first upload. To change it later,
edit it in the plugin's settings page on TRMNL.

## Pushing changes

`trmnlp push` overwrites `src/settings.yml` with the copy the TRMNL service
sends back, which leaves out the polling headers and body (TRMNL still stores
them) and adds your account's plugin ID. `bin/push` pushes and then puts the
file back as it was:

```sh
export TRMNL_API_KEY=user_...      # TRMNL account key, from trmnl.com/account
export TRMNL_PLUGIN_ID=123456      # from the plugin settings address
bin/push
```

## Local development

Keep these values in a `mise.local.toml`, which git ignores, or export them:

```sh
export APPSIGNAL_APP_ID=...                                       # read by .trmnlp.yml
export TRMNL_OAUTH_CLIENT_ID=nUr-tu_3pJcoct2D0XoWZWsGPPNATOdTtjBjEXT6Jrk
trmnlp serve      # preview at http://localhost:4567; click "Connect account" once
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
- The `app:read` token can read every app in the organization you approve,
  unless AppSignal's approval screen lets you narrow it to one app.
