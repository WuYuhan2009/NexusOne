// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NexusOne",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "NexusOne", targets: ["NexusOne"])
    ],
    targets: [
        .executableTarget(
            name: "NexusOne",
            path: "Sources/NexusOne"
        )
    ]
)
