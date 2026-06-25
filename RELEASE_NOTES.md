# Release Notes

## 2.0.0

- Changed `ErrorHandling.Business.Effect.identifyClient(accountId:)` from
  `UUID?` to `String?`.
- Changed `ErrorHandling.Business.Provider.identifyClient(appInstanceId:accountId:)`
  to accept string account ids.
- Updated `ReluxSentryProvider` to pass the string account id directly to Sentry
  scope tags and context.

This is a source-breaking release for callers and provider implementations that
used the old UUID account id contract.

## 1.0.0

- Initial public release with `ReluxErrHandling` abstraction and
  `ReluxSentryProvider` implementation.
