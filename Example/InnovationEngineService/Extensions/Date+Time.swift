import Foundation

extension Date {
    func currentTimeMillis() -> String {
        return String(Int(self.timeIntervalSince1970 * 1000))
    }
}
