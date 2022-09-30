// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Minimal",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Minimal",
            dependencies: []
        ),
        .testTarget(
            name: "MinimalTests",
            dependencies: ["Minimal"]),
    ]
)
