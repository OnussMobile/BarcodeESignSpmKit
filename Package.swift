// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "onuss-features-ios",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ESignView",
            targets: ["ESignView"]
        ),
        .library(
            name: "ScannerView",
            targets: ["ScannerView"]
        ),
        .library(
            name: "StartRouteDialogView",
            targets: ["StartRouteDialogView"]
        ),
    ],
    targets: [
        .target(
            name: "ESignView",
            path: "Sources/ESignView"
        ),
        .target(
            name: "ScannerView",
            path: "Sources/ScannerView"
        ),
        .target(
            name: "StartRouteDialogView",
            path: "Sources/StartRouteDialogView"
        ),
    ]
)
