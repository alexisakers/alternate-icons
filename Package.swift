// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "AlternateIcons",
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files.git", from: "1.11.0")
    ],
    targets: [
        .target(name: "AltKit", dependencies: ["Files"]),
        .target(name: "AlternateIcons", dependencies: ["AltKit"]),
        .testTarget(name: "AltKitTests", dependencies: ["AltKit"])
    ]
)
