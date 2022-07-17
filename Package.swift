// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swiftiger",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.13.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "Swiftiger",
            dependencies: [
                .product(name: "Swifter", package: "swifter"),
                .product(name: "SQLite", package: "SQLite.swift")                
            ]),
        .testTarget(
            name: "SwiftigerTests",
            dependencies: ["Swiftiger"]),
    ]
)
