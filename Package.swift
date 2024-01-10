// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Anima",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "Anima",
            targets: ["Anima"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/b3ll/Decomposed.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Anima",
            dependencies: ["Decomposed"]
        ),
        .testTarget(
            name: "AnimaTests",
            dependencies: ["Anima"]
        ),
    ]
)
