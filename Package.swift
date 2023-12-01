// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Anima",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Anima",
            targets: ["Anima"]),
    ],
    dependencies: [
        .package(url: "https://github.com/b3ll/Decomposed.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Anima",
            dependencies: ["Decomposed"]),
        .testTarget(
            name: "AnimaTests",
            dependencies: ["Anima"]),
    ]
)
