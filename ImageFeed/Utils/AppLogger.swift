import Foundation
import os

/// Централизованный логгер приложения на базе os.Logger (Apple OSLog).
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "ImageFeed"

    static func logger(category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}
