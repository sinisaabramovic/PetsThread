// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "petsthread",
    products: [
        .library(name: "petsthread", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        // 🐘 Non-blocking, event-driven Swift client for PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        
        // Jobs
        .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.1"),
        
        // Leaf
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        
        // Authentication
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Authentication", "Leaf", "Jobs", "FluentSQLite", "FluentPostgreSQL", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

