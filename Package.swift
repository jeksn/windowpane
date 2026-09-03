// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "WindowPane",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "WindowPane", targets: ["WindowPane"])
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", exact: "1.10.0")
    ],
    targets: [
        .target(
            name: "WindowPaneCore",
            path: "Sources/WindowPaneCore"
        ),
        .executableTarget(
            name: "WindowPane",
            dependencies: [
                "WindowPaneCore",
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts")
            ],
            path: "Sources/WindowPane"
        ),
        .executableTarget(
            name: "WindowPaneTests",
            dependencies: ["WindowPaneCore"],
            path: "Tests/WindowPaneTests"
        )
    ],
    swiftLanguageModes: [.v5]
)
