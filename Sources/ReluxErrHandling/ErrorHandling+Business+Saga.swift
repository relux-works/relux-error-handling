import Foundation
import Relux

extension ErrorHandling.Business {
    public protocol ISaga: Relux.Saga {}

    public actor Saga {
        private let provider: any ErrorHandling.Business.Provider
        private let appIdProvider: any ErrorHandling.Business.AppIDProvider

        public init(
            provider: any ErrorHandling.Business.Provider,
            appIdProvider: any ErrorHandling.Business.AppIDProvider
        ) {
            self.provider = provider
            self.appIdProvider = appIdProvider
        }
    }
}

extension ErrorHandling.Business.Saga: ErrorHandling.Business.ISaga {
    public func apply(_ effect: any Relux.Effect) async {
        guard let effect = effect as? ErrorHandling.Business.Effect else {
            return
        }

        switch effect {
        case let .initialize(configuration):
            await provider.configure(configuration.runtimeAdjusted())
        case let .identifyClient(accountId):
            await provider.identifyClient(
                appInstanceId: await appIdProvider.appId,
                accountId: accountId
            )
        case let .sendError(error, data):
            await provider.send(error, data: data)
        case let .sendMessage(message, sender, data):
            await provider.send(message: message, from: sender, data: data)
        }
    }
}
