// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "AlternateIcons",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "AltKit", dependencies: ["Files"]),
        .executableTarget(name: "AlternateIcons", dependencies: ["AltKit"]),
        .testTarget(name: "AltKitTests", dependencies: ["AltKit"])
    ]
)
