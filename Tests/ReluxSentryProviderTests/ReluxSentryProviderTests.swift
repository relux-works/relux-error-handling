import Foundation
import ReluxErrHandling
import Testing
@testable import ReluxSentryProvider

@Suite
struct ReluxSentryProviderTests {
    @Test
    func providerCanBeResolvedAsAbstractErrorHandlingProvider() {
        let provider: any ErrorHandling.Business.Provider = SentryErrorHandlingProvider()

        #expect(provider is SentryErrorHandlingProvider)
    }

    @Test
    func captureCallsAreNoOpWhenSentryIsDisabled() async {
        let provider = SentryErrorHandlingProvider()

        await provider.send(SampleError.boom, data: ["screen": "smoke"])
        await provider.send(message: "diagnostic", from: "test", data: ["kind": "message"])
    }
}

private enum SampleError: Error, CustomStringConvertible, Sendable {
    case boom

    var description: String {
        "boom"
    }
}

