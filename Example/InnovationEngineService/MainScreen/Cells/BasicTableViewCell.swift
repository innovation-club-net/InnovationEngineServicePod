import UIKit
private enum Constants {
    static let inset: CGFloat = 16
    static let smallInset: CGFloat = 6
}

// swiftlint:disable trailing_whitespace
class BasicTableViewCell: UITableViewCell {
    private lazy var subtitleLabel = UILabel()
    private lazy var titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        setupStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(title: String, text: String?) {
        titleLabel.text = title
        subtitleLabel.text = text ?? ""
    }

    func applyAlignment(_ alignment: NSTextAlignment = .center) {
        subtitleLabel.textAlignment = alignment
    }

    func setupStyle() {
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .natural
        subtitleLabel.textAlignment = .natural
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.textColor = .gray
        selectionStyle = .none
    }

    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
    }

    private func setupConstraints() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.inset),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.inset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.inset),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.smallInset),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.inset),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.inset),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.inset)
        ])
    }
}
