import Foundation
import os

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? String(describing: AppLogger.self)

    static func make(for type: Any.Type) -> Logger {
        Logger(subsystem: subsystem, category: String(describing: type))
    }
}
