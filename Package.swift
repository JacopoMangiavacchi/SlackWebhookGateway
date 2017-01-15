import PackageDescription

let package = Package(
    name: "SlackWebhookGateway",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/VeniceX/HTTPServer.git", majorVersion: 0),
        .Package(url: "https://github.com/JacopoMangiavacchi/SlackKit.git", majorVersion: 0, minor: 0),
    ]
)
