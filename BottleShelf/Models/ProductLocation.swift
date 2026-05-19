import Foundation

enum ProductLocation: String, Codable, CaseIterable, Identifiable {
    case vanity
    case bathroom
    case commuteBag
    case travelBag
    case office
    case unopenedStock
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vanity: "梳妆台"
        case .bathroom: "浴室柜"
        case .commuteBag: "通勤包"
        case .travelBag: "旅行包"
        case .office: "公司"
        case .unopenedStock: "未开封囤货"
        case .other: "其他"
        }
    }
}
