// swift-tools-version: 5.6

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
    targets: [
        .target(
            name: "PlanetSiteTemplates",
            resources: [
                .copy("Resources/")
            ]
        ),
        .testTarget(
            name: "PlanetSiteTemplatesTests",
            dependencies: ["PlanetSiteTemplates"]
        ),
    ]
)
