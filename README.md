# Relux Error Handling

Relux Error Handling is a Swift package that gives Relux-based applications a
small, provider-driven error-handling module. The core product exposes only the
Relux abstraction. The Sentry integration is isolated in a separate product so
feature modules can dispatch diagnostics effects without depending on Sentry.

## Products

| Product | Purpose | Sentry dependency |
| --- | --- | --- |
| `ReluxErrHandling` | Defines `ErrorHandling.Business.Effect`, provider protocols, `ErrorHandling.Module`, and `ErrorHandling.Business.Saga`. | No |
| `ReluxSentryProvider` | Provides `SentryErrorHandlingProvider`, an implementation of `ErrorHandling.Business.Provider`. | Yes |

## Requirements

- Swift 6.2
- iOS 16+
- macOS 10.15+
- Relux 9.2+
- Sentry Cocoa 9.19.0 for `ReluxSentryProvider`

## Installation

Add the package to the host app or package that owns composition:

```swift
.package(
    url: "https://github.com/relux-works/relux-error-handling.git",
    from: "2.0.0"
)
```

Feature packages that only dispatch diagnostics effects should depend on
`ReluxErrHandling`. Host applications that provide the concrete implementation
should depend on both `ReluxErrHandling` and `ReluxSentryProvider`.

## Architecture

The module is intentionally split into two dependency layers:

- `ReluxErrHandling` is the abstraction layer. It knows about Relux effects,
  sagas, and provider protocols, but has no Sentry imports.
- `ReluxSentryProvider` is the implementation layer. It adapts
  `SentryErrorHandlingProvider` to the abstract provider protocol.
- The host app resolves the concrete provider and injects it into
  `ErrorHandling.Module`.
- Relux feature modules dispatch `ErrorHandling.Business.Effect` values through
  Relux's normal action dispatching.

## Host App Wiring

Register the provider and module in the host application's composition root:

```swift
import Relux
import ReluxErrHandling
import ReluxSentryProvider

let provider: any ErrorHandling.Business.Provider = SentryErrorHandlingProvider()
let appIDProvider: any ErrorHandling.Business.AppIDProvider = AppIDProvider()

let errorHandlingModule = ErrorHandling.Module(
    provider: provider,
    appIdProvider: appIDProvider
)

await Relux(
    logger: logger,
    appStore: store,
    rootSaga: rootSaga
)
.register {
    errorHandlingModule
}
```

Initialize and send diagnostics through regular Relux actions:

```swift
await actions {
    ErrorHandling.Business.Effect.initialize(
        withKey: sentryDSN,
        enableDebug: false,
        env: "production"
    )
    ErrorHandling.Business.Effect.identifyClient(accountId: firebaseUID)
    ErrorHandling.Business.Effect.sendMessage(
        "Checkout failed",
        sender: "CheckoutFlow",
        data: ["screen": "checkout"]
    )
}
```

`accountId` is intentionally a `String?` so host apps can pass their native
identity value directly, for example a Firebase uid, backend account id, or
RevenueCat app user id.

The saga ignores unrelated Relux actions and forwards only
`ErrorHandling.Business.Effect` values to the configured provider.

## Validation

Run package tests:

```bash
swift test
```

Validate iOS simulator builds for both products:

```bash
xcodebuild -scheme ReluxErrHandling -destination 'generic/platform=iOS Simulator' build
xcodebuild -scheme ReluxSentryProvider -destination 'generic/platform=iOS Simulator' build
```

## Tools

| Tool | Purpose | Command | Outputs |
| --- | --- | --- | --- |
| SwiftPM | Resolve, build, and test the package on the host platform | `swift test` | Build products under `.build/`; captured logs go in `.temp/` |
| xcodebuild | Validate iOS Simulator builds for package products | `xcodebuild -scheme ReluxErrHandling -destination 'generic/platform=iOS Simulator' build` and `xcodebuild -scheme ReluxSentryProvider -destination 'generic/platform=iOS Simulator' build` | Derived data under `DerivedData/` or `.temp/DerivedData-*`; captured logs go in `.temp/` |
| gh | GitHub repository management | `gh repo view relux-works/relux-error-handling` | Remote repository metadata on GitHub |
| git | Version control, release tags, and remotes | `git status --short --branch`, `git tag --list` | Local `.git/` state; pushed branch and tags on `origin` |
| rg | Source and dependency-boundary audits | `rg -n "Sentry" Sources/ReluxErrHandling` | Terminal output or captured logs under `.temp/` |

<!-- relux-ecosystem:start -->

## About Relux Works

This project is part of the open-source ecosystem of
[Relux Works](https://relux.works), an AI-native software development studio.
We build fixed-price MVPs, rescue vibe-coded apps, run local AI inference, and
train teams to work with coding agents. Much of the infrastructure behind that
work is open source.

- Full catalog: [relux.works/en/open-source](https://relux.works/en/open-source/)
- Agentic enablement: [agent harnesses & team training](https://relux.works/en/agentic-enablement/)
- Hire us the agent-native way: point your assistant at `https://api.relux.works/mcp`
- Contact: ivan@relux.works

<!-- relux-ecosystem:end -->

## License

Relux Error Handling is released under the Apache License, Version 2.0. See
[LICENSE](LICENSE) and [NOTICE](NOTICE).