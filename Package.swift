// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacDataCalendar",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "MacDataCalendar", targets: ["MacDataCalendar"]),
    ],
    targets: [
        .executableTarget(
            name: "MacDataCalendar",
            path: "Sources/MacDataCalendar",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "MacDataCalendarTests",
            dependencies: ["MacDataCalendar"],
            path: "Tests/MacDataCalendarTests"
        ),
    ]
)
