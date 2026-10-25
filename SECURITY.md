# Security policy

## Supported versions

Only the current version of the plugin, the one published as the TRMNL recipe
and on the `main` branch, receives fixes. Forked copies do not receive updates;
fork owners apply fixes themselves.

## Reporting a problem

Report security problems privately through GitHub's
[private vulnerability reporting](https://github.com/indiebrain/trmnl-appsignal/security/advisories/new),
not in a public issue. Include what an attacker could do, and the steps to
reproduce it. Do not include real AppSignal tokens.

Examples of what to report:

- A way for the plugin to send an installer's AppSignal token anywhere other
  than `appsignal.com`.
- A way for one installer to see another installer's AppSignal data.
- Setting values or AppSignal data that change the request the plugin sends, or
  inject markup into the screen.

You will get a reply within a week. Once a fix is published, the advisory is
made public with credit to the reporter, unless you would rather stay anonymous.

Problems in TRMNL itself or in AppSignal belong with those companies: report
them to TRMNL support and to [AppSignal](https://www.appsignal.com/security).
