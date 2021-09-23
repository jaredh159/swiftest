// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "Swiftest",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "Swiftest", targets: ["Swiftest"]),
    .library(name: "SwiftestPretty", targets: ["SwiftestPretty"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
    .package(url: "https://github.com/eonist/FileWatcher.git", from: "0.2.3"),
  ],
  targets: [
    .target(
      name: "SwiftestPretty",
      dependencies: [
        .product(name: "Rainbow", package: "Rainbow")
      ]),
    .target(
      name: "Swiftest",
      dependencies: [
        "SwiftestPretty",
        "FileWatcher",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .testTarget(name: "SwiftestTests", dependencies: []),
    .testTarget(name: "SwiftestPrettyTests", dependencies: ["SwiftestPretty"]),
  ]
)
