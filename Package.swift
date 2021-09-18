// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "swiftest",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "swiftest", targets: ["swiftest"]),
    .library(name: "SwiftestLib", targets: ["SwiftestLib"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
  ],
  targets: [
    .target(
      name: "SwiftestLib",
      dependencies: [
        .product(name: "Rainbow", package: "Rainbow")
      ]),
    .target(
      name: "swiftest",
      dependencies: [
        "SwiftestLib",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .testTarget(name: "swiftestTests", dependencies: ["swiftest"]),
  ]
)
