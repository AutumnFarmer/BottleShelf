import Foundation

enum ApplicationSupportDirectory {
    static func prepare() {
        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }

        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
