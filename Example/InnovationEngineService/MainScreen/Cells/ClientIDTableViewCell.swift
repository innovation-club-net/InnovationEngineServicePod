import UIKit

enum BottomLabelState {
    case invalid(String)
    case valid(String)
    case invisible
}

protocol ClientIDTableViewCellProtocol: AnyObject {
    func didTapRestartButton()
    func didTapRestartMultipleButton()
}

private enum Constants {
    static let inset: CGFloat = 16
    static let smallInset: CGFloat = 8
}

// swiftlint:disable trailing_whitespace
class ClientIDTableViewCell: UITableViewCell {
    private lazy var titleLabel  = UILabel()
    private lazy var clientIdLabel = UILabel()
    private lazy var restartButton = UIButton()
    private lazy var restartMultipleButton = UIButton()
    private lazy var bottomLabel = UILabel()
    weak var delegate: ClientIDTableViewCellProtocol?
    
    private var bottomLabelState: BottomLabelState = .invisible {
        didSet {
            updateBottomLabelUI()
        }
    }
    
    private func updateBottomLabelUI() {
        switch bottomLabelState {
        case .invalid(let error):
            bottomLabel.text = error
            bottomLabel.isHidden = false
            bottomLabel.textColor = .red
        case .valid(let message):
            bottomLabel.text = message
            bottomLabel.isHidden = false
            bottomLabel.textColor = .gray
        case .invisible:
            bottomLabel.isHidden = true
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(title: String, text: String?) {
        titleLabel.text = title
        if let text = text {
            clientIdLabel.text = text
        }
    }

    func setupStyle() {
        clientIdLabel.textAlignment = .left
        clientIdLabel.numberOfLines = 0
        clientIdLabel.lineBreakMode = .byWordWrapping
        clientIdLabel.textColor = .gray

        bottomLabel.textAlignment = .center
        bottomLabel.numberOfLines = 0
        bottomLabel.lineBreakMode = .byWordWrapping

        restartMultipleButton.backgroundColor = .purple
        restartMultipleButton.layer.cornerRadius = 16
        restartMultipleButton.setTitle("RESTART", for: .normal)
        restartMultipleButton.setTitleColor(.white, for: .normal)
        restartMultipleButton.setTitleColor(.gray, for: .selected)
        restartMultipleButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        restartMultipleButton.addTarget(self, action: #selector(didTapRestartMultipleButton), for: .touchUpInside)
        
        selectionStyle = .none
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
    }

    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(restartButton)
        contentView.addSubview(restartMultipleButton)
        contentView.addSubview(clientIdLabel)
        contentView.addSubview(bottomLabel)
    }
    
    private func setupConstraints() {
        clientIdLabel.translatesAutoresizingMaskIntoConstraints = false
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartMultipleButton.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.inset),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.inset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.inset),
            clientIdLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.smallInset),
            clientIdLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.inset),
            clientIdLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.inset),
            restartMultipleButton.heightAnchor.constraint(equalToConstant: 44),
            restartMultipleButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            restartMultipleButton.topAnchor.constraint(equalTo: clientIdLabel.bottomAnchor, constant: Constants.inset),
            bottomLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLabel.topAnchor.constraint(equalTo: restartMultipleButton.bottomAnchor, constant: Constants.inset),
            bottomLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc private func didTapRestartButton() {
        delegate?.didTapRestartButton()
    }
    
    @objc private func didTapRestartMultipleButton() {
        delegate?.didTapRestartMultipleButton()
    }
}
