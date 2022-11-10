// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HamRadioKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HamRadioKit",
            targets: ["HamRadioKit"]
        ),
        .library(
            name: "RigControlKit",
            targets: ["RigControlKit"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/drmohundro/SWXMLHash", from: "7.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.0.0"),
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HamRadioKit",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SWXMLHash", package: "SWXMLHash"),
                .product(name: "Gzip", package: "GzipSwift")
            ]),
        .target(
            name: "RigControlKit",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "HamRadioKitTests",
            dependencies: ["HamRadioKit"])
    ]
)
