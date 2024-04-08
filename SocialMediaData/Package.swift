// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SocialMediaData",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "SocialMediaData",
            type: .dynamic,
            targets: ["SocialMediaData"]
        )
    ],
    dependencies: [
       // .package(path: "../SocialMediaNetwork"),
    ],
    targets: [
        .target(
            name: "SocialMediaData",
            dependencies: [
               // .product(name: "SocialMediaNetwork", package: "SocialMediaNetwork", condition: nil),
            ],
            path: "."
        )
    ]
)
