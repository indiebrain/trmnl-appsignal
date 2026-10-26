# AppSignal for TRMNL

A TRMNL plugin that shows the open incidents and monitors of every app in an
AppSignal organization, or of one app. Built for the TRMNL X (1872 by 1404, 16 grays) and still readable on
the original TRMNL.

![The full view on a TRMNL X, with example data](tests/snapshots/linux/appsignal-looks-as-it-did-full-on-v2-v2-full.png)

| View | Shows |
|------|-------|
| Full | Open error count, slow action count, monitors down, latest errors, latest performance issues, and every monitor with its status (TRMNL X in landscape; errors only in portrait) |
| Half (either way) | Open error count, monitors down, latest errors |
| Quadrant | Open error count with a one-line summary, plus the latest error on the TRMNL X |

With more than one app, counts add up across apps, lists merge them newest
first, and each row names its app.

TRMNL polls AppSignal's GraphQL API directly every 15 minutes, so no server of
your own is needed. It signs in with OAuth and asks only for the `app:read`
scope: TRMNL never holds a personal API token, and the token it does hold can
only read, reaches only one organization, and can be revoked on its own.

## Install

1. Open the [AppSignal recipe](https://trmnl.com/recipes/appsignal-518240) on
   TRMNL and click **Install**, or **Fork** to take a copy that does not receive
   updates (see below).
2. On the plugin's settings page, paste
   `SSxE-b54Nak88428BadY9JQeDS0sck3JGgycXSIL2ho` into **OAuth Client ID**,
   leave **OAuth Client Secret** empty, and save. TRMNL does not copy the
   client ID when it installs a recipe. To use your own client instead, see
   [Using your own OAuth client](#using-your-own-oauth-client).
3. Click **Connect with OAuth** and approve read access in AppSignal. AppSignal
   asks you to pick an app, but the plugin can read every app in the
   organization either way.
4. Fill in the organization name, which is the part after `appsignal.com/` in
   the address bar when you open AppSignal (`appsignal.com/<organization>/...`).
   Leave **App** blank to see every app, or enter one app's name (add the
   environment, as in `my-app staging`, to pick one environment).
5. Save, and add the plugin to a playlist.

Enter `demo` as the organization to see example data without connecting.

### Using your own OAuth client

Every install that pastes the client ID above shares one AppSignal OAuth client.
AppSignal rate-limits each user and IP address, not each client, so installs do
not share a limit. When it sees abusive traffic, AppSignal contacts the user
behind it before acting against the client. If AppSignal did revoke the shared
client, every install using it would stop refreshing at once. To keep yours
independent, register your own client and paste its ID in step 2 instead:

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

The `client_id` in the response is the ID to paste. It needs no secret, and
nothing else about the plugin changes.

## What installers trust

Installing the recipe (rather than forking it) means taking every update its
publisher pushes, and each update runs with the installer's AppSignal token. A
publisher, or anyone who takes over the publisher's TRMNL account, could change
where the plugin sends requests and collect those tokens. Each token can only
read, but it reaches every app in the installer's AppSignal organization. To
limit this:

- The publisher keeps two-step sign-in on for TRMNL and GitHub.
- Installers who would rather not take updates choose **Fork**, which copies the
  plugin as it is.
- Anyone can revoke the plugin's access in AppSignal at any time.

## Limits

- AppSignal returns at most 100 open incidents of each type per app, and counts
  of 100 or more show as "99+".
- The request fetches the 8 newest incidents of each type from each app; the
  lists merge them and show the newest 8.
- Monitors are the app's uptime monitors and check-in monitors (cron and
  heartbeat). An uptime monitor counts as down when it has an alert in the
  `OPEN` state; a check-in monitor counts as down when its latest run was
  missed or late.
- An App name that matches nothing shows the apps the organization has.
- A blank or wrong organization name shows AppSignal's "Object not found." An
  expired or revoked connection shows "Request could not be authenticated."

## Contributing

Bug reports, ideas, and pull requests are welcome. [CONTRIBUTING.md](CONTRIBUTING.md)
covers local development, the tests, and running your own copy of the plugin.
Everyone taking part follows the [code of conduct](CODE_OF_CONDUCT.md). Report
security problems privately, as [SECURITY.md](SECURITY.md) describes.

## License

[MIT](LICENSE)
