import Foundation

struct Config {
    static let host = "192.168.1.141"
    static let port = "8000"
    static let pollRate: TimeInterval = 1/60

    static var mjpegFeed: URL {
        return URL(string: "http://\(host):8000")!
    }
}
