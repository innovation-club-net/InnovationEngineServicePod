import Foundation

// swiftlint:disable trailing_whitespace
enum ItemType: CaseIterable {
    case url
    case timeout
    case environment
    case screenID
    case clientID
    case result
    
    var title: String {
        switch self {
        case .url:
            return "Loader server"
        case .environment:
            return "Environment"
        case .timeout:
            return "Timeout"
        case .screenID:
            return "Screen id"
        case .clientID:
            return "Client id"
        default:
            return ""
        }
    }
}

struct Item {
    let type: ItemType
    let title: String?
}
