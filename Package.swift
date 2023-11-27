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
    targets: [
        .target(
            name: "PlanetSiteTemplates",
            resources: [
                .copy("Templates/")
            ]
        ),
        .testTarget(
            name: "PlanetSiteTemplatesTests",
            dependencies: ["PlanetSiteTemplates"]
        ),
    ]
)
