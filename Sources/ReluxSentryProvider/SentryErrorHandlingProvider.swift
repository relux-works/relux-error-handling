import Foundation
import ReluxErrHandling
@preconcurrency import Sentry

public final class SentryErrorHandlingProvider: ErrorHandling.Business.Provider {
    public init() {}

    public func configure(_ configuration: ErrorHandling.Business.Configuration) async {
        await MainActor.run {
            SentrySDK.start { options in
                options.dsn = configuration.key
                options.environment = configuration.environment
                options.debug = configuration.isDebugEnabled
                #if canImport(UIKit)
                options.attachScreenshot = true
                options.attachViewHierarchy = true
                #endif
                options.enableAppHangTracking = true
                options.enableWatchdogTerminationTracking = true
                options.sessionTrackingIntervalMillis = 1_000
            }
        }
    }

    public func identifyClient(appInstanceId: UUID, accountId: UUID?) async {
        await MainActor.run {
            SentrySDK.configureScope { scope in
                let user = User()
                user.userId = appInstanceId.uuidString
                scope.setUser(user)
                scope.setTag(value: appInstanceId.uuidString, key: "appId")

                if let accountId {
                    scope.setTag(value: accountId.uuidString, key: "accountId")
                }

                scope.setContext(
                    value: [
                        "accountId": accountId?.uuidString ?? "",
                        "appId": appInstanceId.uuidString
                    ],
                    key: "account"
                )
            }
        }
    }

    public func send(_ error: any Error & Sendable, data: [String: any Sendable]) async {
        guard SentrySDK.isEnabled else {
            return
        }

        var customData = data.anyValues
        customData["error-message"] = String(describing: error)

        let scope = Scope()
        customData.forEach { key, value in
            scope.setExtra(value: value, key: key)
        }

        SentrySDK.capture(error: error, scope: scope)
    }

    public func send(
        message: String,
        from sender: any Sendable,
        data: [String: any Sendable]
    ) async {
        guard SentrySDK.isEnabled else {
            return
        }

        let scope = Scope()
        scope.setExtra(value: String(reflecting: sender), key: "sender")
        data.anyValues.forEach { key, value in
            scope.setExtra(value: value, key: key)
        }

        SentrySDK.capture(message: message, scope: scope)
    }
}

private extension Dictionary where Key == String, Value == any Sendable {
    var anyValues: [String: Any] {
        mapValues { $0 }
    }
}
