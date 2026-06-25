import Foundation

extension ErrorHandling.Business {
    public struct Configuration: Equatable, Sendable {
        public var key: String
        public var environment: String
        public var isDebugEnabled: Bool

        public init(
            key: String,
            environment: String = "undefined",
            isDebugEnabled: Bool = false
        ) {
            self.key = key
            self.environment = environment
            self.isDebugEnabled = isDebugEnabled
        }

        package func runtimeAdjusted() -> Self {
            var copy = self
            #if targetEnvironment(simulator)
            if !copy.environment.hasSuffix("-simulator") {
                copy.environment += "-simulator"
            }
            #endif
            return copy
        }
    }
}

