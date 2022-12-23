
import Foundation
public struct CloseEvent: Decodable {
    public let experimentId: String?
    public let treatmentUuid: String?
    public let interaction: String?
}
