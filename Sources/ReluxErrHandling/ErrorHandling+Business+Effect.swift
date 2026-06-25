import Foundation
import Relux

extension ErrorHandling.Business {
    public enum Effect: Relux.Effect {
        case initialize(configuration: Configuration)
        case sendError(
            any Error & Sendable,
            data: [String: any Sendable] = [:]
        )
        case sendMessage(
            String,
            sender: any Sendable,
            data: [String: any Sendable] = [:]
        )
        case identifyClient(accountId: UUID?)
    }
}

public extension ErrorHandling.Business.Effect {
    static func initialize(
        withKey key: String,
        enableDebug: Bool = false,
        env: String = "undefined"
    ) -> Self {
        .initialize(
            configuration: ErrorHandling.Business.Configuration(
                key: key,
                environment: env,
                isDebugEnabled: enableDebug
            )
        )
    }
}
