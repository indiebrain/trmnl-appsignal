# CIR-005: Show every app in the organization, or one named app

## Intent
Let one screen watch a whole AppSignal organization, and still allow a screen
for a single app. Picking an app when connecting does not limit the token: it
reads every app in the organization, so the plugin cannot rely on that choice.

## Behavior
- GIVEN a blank App setting
- WHEN any view is drawn
- THEN counts add up across every app, the error, performance and monitor lists
  merge every app's entries (incidents newest first, monitors down first), each
  row names its app, and the title bar reads "All apps (N)"

- GIVEN an App setting matching an app's name, or its name and environment,
  ignoring case and surrounding spaces
- WHEN any view is drawn
- THEN only the matching app or apps are shown; with one match, rows carry no
  app name and the title bar names the app and environment

- GIVEN an App setting that matches no app
- WHEN any view is drawn
- THEN the screen names the setting and lists the organization's apps

## Constraints
- The `app:read` token reads every app in the organization, whatever app was
  picked on AppSignal's approval screen.
- Liquid cannot sort a list of lists, or add fields to a parsed object, so the
  plugin writes each incident out as JSON with its app label and time in
  seconds, parses the result, and sorts it with `sort`.
- The request asks each app for its 8 newest incidents of each type, so a merged
  list of 8 is always complete.

## Decisions
- A blank setting means every app. Rejected: the first app AppSignal lists,
  which depends on an order the installer cannot see or change.
- Rows add the environment to the app name only when two shown apps share a
  name, which keeps the common case short.
- The demo data has two apps, so the marketplace picture shows the default
  mode.

## Date
2026-10-25
