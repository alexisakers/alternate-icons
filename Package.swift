// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "AlternateIcons",
    targets: [
        Target(name: "AltKit"),
        Target(name: "AlternateIcons", dependencies: ["AltKit"])
    ]
)
