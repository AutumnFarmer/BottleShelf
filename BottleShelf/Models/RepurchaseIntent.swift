import Foundation

enum RepurchaseIntent: String, Codable, CaseIterable, Identifiable {
    case yes
    case no
    case unsure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .yes: "会回购"
        case .no: "不回购"
        case .unsure: "再看看"
        }
    }
}
