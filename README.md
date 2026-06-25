# relux-error-handling

Reusable Relux error handling for Swift packages and iOS host apps.

## Products

- `ReluxErrHandling`: Relux-facing abstraction. It defines `ErrorHandling.Business.Effect`, provider protocols, `ErrorHandling.Module`, and `ErrorHandling.Business.Saga`. It does not depend on Sentry.
- `ReluxSentryProvider`: Sentry-backed provider implementation. It is the only product that depends on `getsentry/sentry-cocoa`.

## Usage

```swift
import ReluxErrHandling
import ReluxSentryProvider

let provider = SentryErrorHandlingProvider()
let module = ErrorHandling.Module(
    provider: provider,
    appIdProvider: appIdProvider
)
```

Register `module` with the host app's Relux composition. Feature modules should depend on `ReluxErrHandling` and dispatch `ErrorHandling.Business.Effect` values. The host app owns the concrete provider wiring.

## Tools

| Tool | Purpose | Command | Outputs |
| --- | --- | --- | --- |
| SwiftPM | Resolve, build, and test the package on the host platform | `swift test` | Build products under `.build/`; captured logs go in `.temp/` |
| xcodebuild | Validate iOS Simulator builds for package products | `xcodebuild -scheme ReluxErrHandling -destination 'generic/platform=iOS Simulator' build` and `xcodebuild -scheme ReluxSentryProvider -destination 'generic/platform=iOS Simulator' build` | Derived data under `DerivedData/` or `.temp/DerivedData-*`; captured logs go in `.temp/` |
| task-board | Local task tracking | `task-board q --format compact 'summary()'` | Board files under `.task-board/` |
| GitHub CLI | Create and inspect the GitHub repository | `gh repo view relux-works/relux-error-handling` | Remote repository metadata on GitHub |
| git | Version control, tags, and remotes | `git status --short --branch` | Local `.git/` state; pushed branch and tags on `origin` |
| ripgrep | Verify dependency boundaries and source text audits | `rg -n "Sentry" Sources/ReluxErrHandling` | Terminal output; captured audit logs should go in `.temp/` when needed |

## Architecture

See [.spec/architecture.md](.spec/architecture.md).
