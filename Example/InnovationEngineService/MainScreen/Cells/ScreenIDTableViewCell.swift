import UIKit

protocol ScreenIDTableViewCellProtocol: AnyObject {
    func didEndEditing(screenId: String)
}

class ScreenIDTableViewCell: UITableViewCell {
    private lazy var textField = UITextField()
    weak var delegate: ScreenIDTableViewCellProtocol?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with text: String?) {
        if let text = text {
            textField.text = text
        }
    }

    func setupStyle() {
        textField.placeholder = "Screen id"
        textField.borderStyle = .none
        textField.returnKeyType = .done
        textField.clearButtonMode = .always
        selectionStyle = .none
    }

    private func addSubviews() {
        contentView.addSubview(textField)
        textField.delegate = self
    }

    private func setupConstraints() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}

extension ScreenIDTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let screenId = textField.text else { return }
        delegate?.didEndEditing(screenId: screenId)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
}
