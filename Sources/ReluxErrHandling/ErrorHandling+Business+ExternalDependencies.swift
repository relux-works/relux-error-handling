import Foundation

extension ErrorHandling.Business {
    public protocol AppIDProvider: Sendable {
        var appId: UUID { get async }
    }

    public typealias IAppIdProvider = AppIDProvider

    public protocol Provider: Sendable {
        func configure(_ configuration: Configuration) async
        func identifyClient(appInstanceId: UUID, accountId: UUID?) async
        func send(_ error: any Error & Sendable, data: [String: any Sendable]) async
        func send(message: String, from sender: any Sendable, data: [String: any Sendable]) async
    }

    public typealias IProvider = Provider
}

