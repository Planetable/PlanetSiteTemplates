// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "PlanetSiteTemplates",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "PlanetSiteTemplates",
            targets: ["PlanetSiteTemplates"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
        .package(url: "https://github.com/stencilproject/Stencil.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "PlanetSiteTemplates",
            resources: [
                .copy("Resources/")
            ]
        ),
        .testTarget(
            name: "PlanetSiteTemplatesTests",
            dependencies: [
                "PlanetSiteTemplates",
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "Stencil", package: "Stencil"),
            ]
        ),
    ]
)
