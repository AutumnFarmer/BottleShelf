import SwiftUI

enum ProductStatus: String, Codable, CaseIterable, Identifiable {
    case unopened
    case inUse
    case expiringSoon
    case expired
    case emptied
    case discarded

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .unopened: "未开封"
        case .inUse: "使用中"
        case .expiringSoon: "临期"
        case .expired: "超过建议期"
        case .emptied: "已空瓶"
        case .discarded: "已丢弃"
        }
    }

    var tint: Color {
        switch self {
        case .unopened: AppTheme.sage
        case .inUse: AppTheme.sage
        case .expiringSoon: AppTheme.warning
        case .expired: AppTheme.danger
        case .emptied: AppTheme.muted
        case .discarded: AppTheme.muted
        }
    }

    var background: Color {
        switch self {
        case .unopened: AppTheme.sage.opacity(0.18)
        case .inUse: AppTheme.sage.opacity(0.18)
        case .expiringSoon: AppTheme.warning.opacity(0.16)
        case .expired: AppTheme.danger.opacity(0.16)
        case .emptied: AppTheme.muted.opacity(0.12)
        case .discarded: AppTheme.muted.opacity(0.12)
        }
    }
}
