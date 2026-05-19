import Foundation

extension Date {
    var shortDateText: String {
        DateFormatter.shortProductDate.string(from: self)
    }
}

extension DateFormatter {
    static let shortProductDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
}
