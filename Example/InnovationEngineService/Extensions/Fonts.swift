import Foundation

// swiftlint:disable trailing_whitespace
enum Fonts {
    case muliRegular
    case muliBold
    case isidoraSemibold
    // Not in use
    case isidoraRegular
    case muliSemibold
    
    var fontName: String {
        switch self {
        case .muliRegular, .muliBold:
            return "Muli"
        case .isidoraSemibold:
            return "IsidoraSansAlt_SemiBold"
        default:
            // What are names for isidoraRegular, muliSemibold?
            return ""
        }
    }
    
    var fileName: String {
        switch self {
        case .muliRegular:
            return "muli_regular"
        case .muliBold:
            return "muli_bold"
        case .isidoraSemibold:
            return "isidora_sans_alt_semibold"
        case .isidoraRegular:
            return "isidora_sans_alt_regular"
        case .muliSemibold:
            return "muli_semibold"
        }
    }
}
