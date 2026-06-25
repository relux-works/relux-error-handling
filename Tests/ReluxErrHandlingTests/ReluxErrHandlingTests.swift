import Foundation
import Relux
import Testing
@testable import ReluxErrHandling

@Suite
struct ReluxErrHandlingTests {
    @Test
    func moduleInjectsProviderIntoSaga() async throws {
        let provider = RecordingProvider()
        let appId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let accountId = "firebase-user-2"

        let module = ErrorHandling.Module(
            provider: provider,
            appIdProvider: StaticAppIDProvider(appId: appId)
        )

        #expect(module.dependencies.isEmpty)
        #expect(module.states.isEmpty)
        #expect(module.sagas.count == 1)

        let saga = try #require(module.sagas.first)
        await saga.apply(ErrorHandling.Business.Effect.identifyClient(accountId: accountId))

        #expect(await provider.snapshot() == [
            .identify(appId: appId, accountId: accountId)
        ])
    }

    @Test
    func sagaForwardsConfigurationEffectToProvider() async {
        let provider = RecordingProvider()
        let saga = ErrorHandling.Business.Saga(
            provider: provider,
            appIdProvider: StaticAppIDProvider(appId: UUID())
        )
        let configuration = ErrorHandling.Business.Configuration(
            key: "diagnostics-key",
            environment: "production",
            isDebugEnabled: true
        )

        await saga.apply(ErrorHandling.Business.Effect.initialize(configuration: configuration))

        #expect(await provider.snapshot() == [
            .configure(configuration.runtimeAdjusted())
        ])
    }

    @Test
    func sagaKeepsLegacyInitializeEffectShape() async {
        let provider = RecordingProvider()
        let saga = ErrorHandling.Business.Saga(
            provider: provider,
            appIdProvider: StaticAppIDProvider(appId: UUID())
        )

        await saga.apply(
            ErrorHandling.Business.Effect.initialize(
                withKey: "legacy-key",
                enableDebug: true,
                env: "qa"
            )
        )

        let expected = ErrorHandling.Business.Configuration(
            key: "legacy-key",
            environment: "qa",
            isDebugEnabled: true
        )

        #expect(await provider.snapshot() == [
            .configure(expected.runtimeAdjusted())
        ])
    }

    @Test
    func sagaForwardsErrorAndMessageEffects() async {
        let provider = RecordingProvider()
        let saga = ErrorHandling.Business.Saga(
            provider: provider,
            appIdProvider: StaticAppIDProvider(appId: UUID())
        )

        await saga.apply(
            ErrorHandling.Business.Effect.sendError(
                SampleError.boom,
                data: ["screen": "checkout"]
            )
        )
        await saga.apply(
            ErrorHandling.Business.Effect.sendMessage(
                "route changed",
                sender: "Router",
                data: ["route": "confirm"]
            )
        )

        #expect(await provider.snapshot() == [
            .error(description: "boom", data: ["screen": "checkout"]),
            .message(message: "route changed", sender: "Router", data: ["route": "confirm"])
        ])
    }
}

private struct StaticAppIDProvider: ErrorHandling.Business.AppIDProvider {
    let appId: UUID
}

private enum SampleError: Error, CustomStringConvertible, Sendable {
    case boom

    var description: String {
        "boom"
    }
}

private actor RecordingProvider: ErrorHandling.Business.Provider {
    enum Event: Equatable, Sendable {
        case configure(ErrorHandling.Business.Configuration)
        case identify(appId: UUID, accountId: String?)
        case error(description: String, data: [String: String])
        case message(message: String, sender: String, data: [String: String])
    }

    private var events: [Event] = []

    func configure(_ configuration: ErrorHandling.Business.Configuration) async {
        events.append(.configure(configuration))
    }

    func identifyClient(appInstanceId: UUID, accountId: String?) async {
        events.append(.identify(appId: appInstanceId, accountId: accountId))
    }

    func send(_ error: any Error & Sendable, data: [String: any Sendable]) async {
        events.append(
            .error(
                description: String(describing: error),
                data: stringify(data)
            )
        )
    }

    func send(message: String, from sender: any Sendable, data: [String: any Sendable]) async {
        events.append(
            .message(
                message: message,
                sender: String(describing: sender),
                data: stringify(data)
            )
        )
    }

    func snapshot() -> [Event] {
        events
    }

    private func stringify(_ data: [String: any Sendable]) -> [String: String] {
        data.mapValues { String(describing: $0) }
    }
}
