// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RegexTester",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "RegexTester", targets: ["RegexTester"]),
    ],
    targets: [
        .target(name: "RegexTester", path: "Sources",
                swiftSettings: [.unsafeFlags(["-strict-concurrency=complete"])]),
        .testTarget(name: "RegexTesterTests", dependencies: ["RegexTester"], path: "Tests"),
    ]
)
