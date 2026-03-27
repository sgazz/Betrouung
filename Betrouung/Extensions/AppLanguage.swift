import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case german = "de"
    case serbian = "sr"

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .english: return "EN"
        case .german: return "DE"
        case .serbian: return "SR"
        }
    }
}
