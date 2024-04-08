// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SocialMediaUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "SocialMediaUI",
            type: .dynamic,
            targets: ["SocialMediaUI"]
        )
    ],
    dependencies: [
        .package(path: "../SocialMediaData"),
    ],
    targets: [
        .target(
            name: "SocialMediaUI",
            dependencies: [
                .product(name: "SocialMediaData", package: "SocialMediaData", condition: nil),
            ],
            path: "."
        )
    ]
)

