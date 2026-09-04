// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RegexTester",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "RegexTester", targets: ["RegexTester"]),
    ],
    targets: [
        .target(name: "RegexTester", path: "Sources",
                swiftSettings: [.swiftLanguageMode(.v6)]),
        .testTarget(name: "RegexTesterTests", dependencies: ["RegexTester"], path: "Tests"),
    ]
)
