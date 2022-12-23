import Foundation

public class FontAsset: Codable {
    var familyName: String
    var fileContentBase64: String
    var descriptors: [String: String]?
    init(familyName: String, fileContentBase64: String, descriptors: [String: String]? = nil) {
        self.familyName = familyName
        self.fileContentBase64 = fileContentBase64
        self.descriptors = descriptors
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(familyName, forKey: .familyName)
        try container.encode(fileContentBase64, forKey: .fileContentBase64)
        if let descriptors = descriptors {
            try container.encode(descriptors, forKey: .descriptors)
        } else {
            try container.encodeNil(forKey: .descriptors)
        }
    }
}
