import Foundation
import UIKit

protocol ReusableCell: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableCell where Self: UITableViewCell {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableCell {}
