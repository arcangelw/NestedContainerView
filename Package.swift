// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WZNestedContainerView",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "NestedContainerView",
            targets: ["NestedContainerView"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NestedContainerView",
            dependencies: ["NestedProxy"],
            path: "Sources/Container"
        ),
        .target(
            name: "NestedProxy",
            dependencies: [],
            path: "Sources/Proxy"
        ),
        .testTarget(
            name: "WZNestedContainerViewTests",
            dependencies: ["NestedContainerView"],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
