# Contributing

Thanks for helping improve AppSignal for TRMNL. Everyone taking part follows the
[code of conduct](CODE_OF_CONDUCT.md). Report security problems privately, as
[SECURITY.md](SECURITY.md) describes, not in a public issue.

## Issues

Search the open issues first. A bug report is easiest to act on when it names
the device (original TRMNL or TRMNL X), the view, the orientation, and what the
screen shows. Leave out tokens, organization names, and app names you would
rather keep private: enter `demo` as the organization and check whether the
problem still happens with example data.

## Pull requests

- Keep each pull request to one change, and open an issue first for anything
  large, so we can agree on the approach before you build it.
- Run the linter and the tests (below), and include any test pictures you
  recorded again.
- When a change chooses between alternatives and the wrong choice would cause a
  real problem, add a Change Intent Record in [`docs/cir/`](docs/cir/) that
  explains the choice. The existing records show the format.
- Write commit messages that say what the change does and why, in the present
  tense.

## Layout

| Path | Holds |
|------|-------|
| `src/settings.yml` | Plugin settings: the GraphQL request, OAuth settings, and the fields installers fill in |
| `src/shared.liquid` | Markup every view uses, including the demo data |
| `src/full.liquid`, `src/half_*.liquid`, `src/quadrant.liquid` | One file per view size |
| `tests/` | Tests, the canned AppSignal response, and the test pictures |
| `docs/cir/` | Change Intent Records |
| `bin/push` | Uploads the plugin to TRMNL |

## Local development

Install Ruby and the TRMNL preview tool (`trmnlp`) with [mise](https://mise.jdx.dev):

```sh
mise install
```

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
mise exec -- trmnlp serve   # preview at http://localhost:4567; click "Connect account" once
mise exec -- trmnlp lint
```

The preview reads `APPSIGNAL_ORGANIZATION` when it starts, so restart it after
changing `mise.local.toml`. Typing in the preview's **Custom Fields** box
rewrites `.trmnlp.yml` with the value you typed; restore it with
`git checkout -- .trmnlp.yml` before committing.

The preview tool and TRMNL disagree on how to switch on PKCE (the extra check
AppSignal needs for clients without a secret): TRMNL keeps only
`oauth_pkce_enabled: 'yes'`, and `trmnlp serve` accepts only `'true'`, hiding
the **Connect account** banner otherwise. To connect locally, change it to
`'true'` until the banner says connected, then change it back before pushing.
The preview keeps the token after that.

## Tests

The tests need Firefox and ImageMagick, so run them in Docker. Use the Intel
image even on an ARM Mac: fonts draw a pixel differently on ARM, and the
pictures must match the ones GitHub Actions draws.

```sh
docker run --rm --platform linux/amd64 -v "$PWD":/plugin trmnl/trmnlp:v0.32.3 test
docker run --rm --platform linux/amd64 -v "$PWD":/plugin trmnl/trmnlp:v0.32.3 test --update   # record the pictures again
```

They render every view against a canned response (`tests/fixtures/`) on the
original TRMNL (`og_plus`) and the TRMNL X (`v2`), in landscape and on the
TRMNL X in portrait, and compare against the pictures in `tests/snapshots/`.
After recording the pictures again, look at the ones that changed before
committing them.

## Running your own copy

To try a change on a real device, upload the plugin to your own TRMNL account
as a private plugin.

1. Create the plugin with your TRMNL account API key (from
   trmnl.com/account). The upload prints the plugin settings address; the
   number at its end is the plugin ID. Put both in `mise.local.toml`.

   ```sh
   TRMNL_API_KEY=user_... mise exec -- trmnlp push
   git checkout -- src/settings.yml   # see "Pushing changes" below
   ```

2. Paste the TRMNL client ID from the table below into the plugin's OAuth
   settings on TRMNL, and leave the client secret empty. Uploads do not set it,
   and later uploads leave it alone.
3. Connect and fill in the organization as the [README](README.md#install)
   describes.

### Pushing changes

`trmnlp push` overwrites `src/settings.yml` with the copy the TRMNL service
sends back, which leaves out the polling headers and body (TRMNL still stores
them) and adds your account's plugin ID. `bin/push` pushes and then puts the
file back as it was:

```sh
mise exec -- bin/push
```

### OAuth clients

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

### If AppSignal revokes the TRMNL client

Installs that use the TRMNL client ID above stop refreshing and show "Request
could not be authenticated." Installs with their own client keep working. To
recover:

1. Register a new client with the command above, using the TRMNL callback.
2. Replace the old ID everywhere it appears (`git grep <old client ID>`): the
   `oauth_client_id` and setup steps in `src/settings.yml`, the README install
   steps, and the table above.
3. Push with `bin/push`, then paste the new ID into your own plugin's OAuth
   settings on TRMNL, since uploads do not set it.
4. Tell installers to paste the new ID and connect again: open a pinned GitHub
   issue, and say so at the top of the About text in `src/settings.yml`.

## License

By contributing, you agree that your contributions are licensed under the
[MIT License](LICENSE).
