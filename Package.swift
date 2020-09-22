// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Trellio",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
    ],
    products: [
        .library(name: "Trellio", targets: ["Trellio"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Patrik-svobodik/Cartography", .branch("tvOS-fix")),
        .package(url: "https://github.com/Patrik-svobodik/PTDList", .branch("main")),
    ],
    targets: [
        .target(name: "Trellio", dependencies: ["Cartography", "PTDList"]),
        .testTarget(name: "TrellioTests", dependencies: ["Trellio"]),
    ]
)
