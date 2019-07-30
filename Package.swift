// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Reggie",
    products: [
        .library(
            name: "Reggie",
            targets: ["Reggie"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Reggie",
            dependencies: [],
            path: "Source",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "Reggie Tests",
            dependencies: ["Reggie"],
            path: "Tests",
            exclude: ["LinuxMain.swift", "Info.plist"]
        )
    ]
)
