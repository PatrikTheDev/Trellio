// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Trellio",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Trellio", targets: ["Trellio"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/robb/Cartography", .branch("master")),
        .package(url: "https://github.com/Patrik-svobodik/PTDList", .branch("main")),
    ],
    targets: [
        .target(name: "Trellio", dependencies: ["Cartography", "PTDList"]),
        .testTarget(name: "TrellioTests", dependencies: ["Trellio"]),
    ]
)
