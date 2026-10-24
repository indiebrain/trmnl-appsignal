# AppSignal for TRMNL

A private TRMNL plugin that shows an AppSignal app's open incidents and uptime
monitors. Built for the TRMNL X (1872 by 1404, 16 grays) and still readable on
the original TRMNL.

| View | Shows |
|------|-------|
| Full | Open error count, slow action count, monitors down, latest errors, latest performance issues (errors only in portrait) |
| Half (either way) | Open error count, monitors down, latest errors |
| Quadrant | Open error count with a one-line summary |

TRMNL polls AppSignal's GraphQL API directly every 15 minutes, so no server of
your own is needed. It signs in with OAuth and asks only for the `app:read`
scope: TRMNL never holds a personal API token, and the token it does hold can
only read, belongs to one organization, and can be revoked on its own.

## What installers trust

Installing the recipe (rather than forking it) means taking every update its
publisher pushes, and each update runs with the installer's AppSignal token. A
publisher, or anyone who takes over the publisher's TRMNL account, could change
where the plugin sends requests and collect those tokens. Each token can only
read, and only what its installer approved. To limit this:

- The publisher keeps two-step sign-in on for TRMNL and GitHub.
- Installers who would rather not take updates choose **Fork**, which copies the
  plugin as it is.
- Anyone can revoke the plugin's access in AppSignal at any time.

## Setup

1. Install Ruby and the TRMNL preview tool (`trmnlp`) with `mise install`.
2. Create the plugin in your TRMNL account with your TRMNL account API key
   (from trmnl.com/account). The push prints the plugin settings address; the
   number at its end is the plugin ID.

   ```sh
   TRMNL_API_KEY=user_... trmnlp push
   git checkout -- src/settings.yml   # see "Pushing changes" below
   ```

3. In TRMNL, open the plugin, click **Connect with OAuth**, approve read
   access in AppSignal, and pick the app you want on the screen.
4. Fill in the organization name, which is the part after `appsignal.com/` in
   the address bar when you open AppSignal (`appsignal.com/<organization>/...`),
   and add the plugin to your playlist. The screen shows the first app in the
   organization that the token can read.

Enter `demo` as the organization to see example data without connecting. Use it
when generating the marketplace picture, so it does not show your own app.

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

Uploads do not set the client ID on TRMNL. Paste it once into the plugin's
OAuth settings on TRMNL (leave the client secret empty), and later uploads leave
it alone.

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

`mise.toml` sets the Ruby version and the local OAuth client ID. Put your own
values in a `mise.local.toml`, which git ignores:

```toml
[env]
APPSIGNAL_ORGANIZATION = "your-org"   # read by .trmnlp.yml; "demo" works too
TRMNL_API_KEY = "user_..."            # for bin/push
TRMNL_PLUGIN_ID = "123456"            # for bin/push
```

Then:

```sh
mise install
mise exec -- trmnlp serve   # preview at http://localhost:4567; click "Connect account" once
mise exec -- trmnlp lint
```

The preview tool and TRMNL disagree on how to switch on PKCE (the extra check
AppSignal needs for clients without a secret): TRMNL keeps only
`oauth_pkce_enabled: 'yes'`, and `trmnlp serve` accepts only `'true'`, hiding
the **Connect account** banner otherwise. To connect locally, change it to
`'true'` until the banner says connected, then change it back before pushing.
The preview keeps the token after that.

The tests need Firefox and ImageMagick, so run them in Docker. Use the Intel
image even on an ARM Mac: fonts draw a pixel differently on ARM, and the
pictures must match the ones GitHub Actions draws.

```sh
docker run --rm --platform linux/amd64 -v "$PWD":/plugin trmnl/trmnlp:v0.32.3 test
docker run --rm --platform linux/amd64 -v "$PWD":/plugin trmnl/trmnlp:v0.32.3 test --update   # re-record snapshots
```

They render every view against a canned response (`tests/fixtures/`) on the
original TRMNL (`og_plus`) and the TRMNL X (`v2`), in landscape and on the
TRMNL X in portrait, and compare against the pictures in `tests/snapshots/`.

## Limits

- Counts stop at 100 per incident type and show as "99+" beyond that.
- A monitor counts as down when it has an alert in the `OPEN` state.
- AppSignal asks which app to allow when you connect. A token limited to that
  app should leave only that app in the organization list. This is untested with
  an organization that has several apps; until then the screen shows the first
  app the token can read.
- A blank or wrong organization name shows AppSignal's "Object not found." An
  expired or revoked connection shows "Request could not be authenticated."
