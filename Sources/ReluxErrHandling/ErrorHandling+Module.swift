import Foundation
import Relux

extension ErrorHandling {
    public final class Module: Relux.Module {
        public let dependencies: [any Relux.Module] = []
        public let states: [any Relux.AnyState] = []
        public let sagas: [any Relux.Saga]

        public let provider: any ErrorHandling.Business.Provider

        public init(
            provider: any ErrorHandling.Business.Provider,
            appIdProvider: any ErrorHandling.Business.AppIDProvider
        ) {
            self.provider = provider
            let saga: any ErrorHandling.Business.ISaga = ErrorHandling.Business.Saga(
                provider: provider,
                appIdProvider: appIdProvider
            )
            self.sagas = [saga]
        }
    }
}

