// swift-tools-version: 5.9
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
        .target(name: "RegexTester", path: "Sources"),
        .testTarget(name: "RegexTesterTests", dependencies: ["RegexTester"], path: "Tests"),
    ]
)
