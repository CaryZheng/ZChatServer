// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ZChatServer",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc.2"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc.2"),
        .package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", from: "17.0.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor"]),
        .target(name: "Run", dependencies: ["App", "SwiftyJSON"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

