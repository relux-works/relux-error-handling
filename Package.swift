// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "relux-error-handling",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "ReluxErrHandling",
            targets: ["ReluxErrHandling"]
        ),
        .library(
            name: "ReluxSentryProvider",
            targets: ["ReluxSentryProvider"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/relux-works/swift-relux.git", from: "9.2.0"),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", exact: "9.19.0")
    ],
    targets: [
        .target(
            name: "ReluxErrHandling",
            dependencies: [
                .product(name: "Relux", package: "swift-relux")
            ],
            path: "Sources/ReluxErrHandling"
        ),
        .target(
            name: "ReluxSentryProvider",
            dependencies: [
                "ReluxErrHandling",
                .product(name: "Sentry", package: "sentry-cocoa")
            ],
            path: "Sources/ReluxSentryProvider"
        ),
        .testTarget(
            name: "ReluxErrHandlingTests",
            dependencies: [
                "ReluxErrHandling",
                .product(name: "Relux", package: "swift-relux")
            ],
            path: "Tests/ReluxErrHandlingTests"
        ),
        .testTarget(
            name: "ReluxSentryProviderTests",
            dependencies: [
                "ReluxErrHandling",
                "ReluxSentryProvider"
            ],
            path: "Tests/ReluxSentryProviderTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
