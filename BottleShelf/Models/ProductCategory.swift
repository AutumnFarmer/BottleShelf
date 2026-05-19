import Foundation

enum ProductCategory: String, Codable, CaseIterable, Identifiable {
    case cleanser
    case toner
    case serum
    case cream
    case sunscreen
    case mask
    case baseMakeup
    case lip
    case eyeMakeup
    case perfume
    case sample
    case tool
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cleanser: "洁面"
        case .toner: "水/喷雾"
        case .serum: "精华"
        case .cream: "乳液/面霜"
        case .sunscreen: "防晒"
        case .mask: "面膜"
        case .baseMakeup: "粉底/底妆"
        case .lip: "口红/唇釉"
        case .eyeMakeup: "眼妆"
        case .perfume: "香水"
        case .sample: "小样"
        case .tool: "工具"
        case .other: "其他"
        }
    }
}
