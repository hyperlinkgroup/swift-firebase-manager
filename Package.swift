// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseManager",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_14)
    ],
    products: [
        .library(
            name: "FirebaseManagerPackage",
            targets: [
                "FirebaseStorageManager"
            ])
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        .target(
            name: "FirebaseFirestoreManager",
            dependencies: [
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk")
            ],
            path: "Sources/FirestoreManager"
        ),
        .target(
            name: "FirebaseStorageManager",
            dependencies: [
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk")
            ],
            path: "Sources/StorageManager"
        )
    ]
)
