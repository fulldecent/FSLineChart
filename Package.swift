// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "FSLineChart",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "FSLineChart",
            targets: ["FSLineChart"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FSLineChart",
            dependencies: []
        ),
        .testTarget(
            name: "FSLineChartTests",
            dependencies: ["FSLineChart"]
        )
    ]
)
