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
    targets: [
        .target(
            name: "Anima",
            dependencies: []
        ),
        .testTarget(
            name: "AnimaTests",
            dependencies: ["Anima"]
        ),
    ]
)
