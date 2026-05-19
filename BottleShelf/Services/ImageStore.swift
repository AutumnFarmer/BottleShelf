import Foundation
import UIKit

enum ImageStore {
    private static let folderName = "ProductImages"

    static func saveImageData(_ data: Data, productID: UUID) -> String? {
        guard let compressed = compressedJPEGData(from: data) else {
            return nil
        }

        let fileName = "\(productID.uuidString).jpg"
        let url = imageDirectory.appendingPathComponent(fileName)

        do {
            try FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
            try compressed.write(to: url, options: [.atomic])
            return fileName
        } catch {
            return nil
        }
    }

    static func deleteImage(fileName: String?) {
        guard let fileName else { return }
        try? FileManager.default.removeItem(at: imageDirectory.appendingPathComponent(fileName))
    }

    static func uiImage(fileName: String?) -> UIImage? {
        guard let fileName else { return nil }
        return UIImage(contentsOfFile: imageDirectory.appendingPathComponent(fileName).path)
    }

    private static var imageDirectory: URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return baseURL.appendingPathComponent(folderName, isDirectory: true)
    }

    private static func compressedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let maxDimension: CGFloat = 1200
        let longestSide = max(image.size.width, image.size.height)

        guard longestSide > maxDimension else {
            return image.jpegData(compressionQuality: 0.82)
        }

        let scale = maxDimension / longestSide
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized.jpegData(compressionQuality: 0.82)
    }
}
