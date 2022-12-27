import UIKit
import InnovationEngineService

// swiftlint:disable all
class ViewController: UIViewController {
    private let tableView = UITableView()
    private var items = [Item]()
    private let heightTableHeaderView: CGFloat = 24.0
    private lazy var activityIndicator = UIActivityIndicatorView()

    private let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupDelegates()
        setupTableView()
        updateTableViewDataSource()
        setupConstrains()
        style()
        setupEngine()
    }

    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.register(BasicTableViewCell.self, forCellReuseIdentifier: BasicTableViewCell.defaultReuseIdentifier)
        tableView.register(ScreenIDTableViewCell.self,
                           forCellReuseIdentifier: ScreenIDTableViewCell.defaultReuseIdentifier)
        tableView.register(ClientIDTableViewCell.self,
                           forCellReuseIdentifier: ClientIDTableViewCell.defaultReuseIdentifier)
    }

    private func setupDelegates() {
        viewModel.presenter = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupTableView() {
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView
        = UIView(
            frame: CGRect(
                origin: .zero,
                size: CGSize(
                    width: tableView.frame.width,
                    height: self.heightTableHeaderView)
            )
        )
    }

    private func updateTableViewDataSource() {
        items = [
            Item(type: .url, title: viewModel.loaderServer),
            Item(type: .timeout, title: String(viewModel.timeout)),
            Item(type: .environment, title: viewModel.environment),
            Item(type: .screenID, title: viewModel.screenID),
            Item(type: .clientID, title: viewModel.clientId)
        ]

        if let closeEvent = viewModel.closeEvent {
            items.append(.init(type: .result, title: closeEvent.interaction))
        }

        if !viewModel.error.isEmpty {
            items.append(.init(type: .result, title: viewModel.error))
        }
        tableView.reloadData()
    }

    private func setupConstrains() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func style() {
        activityIndicator.hidesWhenStopped = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.sizeToFit()
        title = "My Application"
    }

    
    ///
    /// Configure the Innovation Engine
    ///
    private func setupEngine() {
        // Set the client ID that will be sent along the requests to the backend
        InnovationEngine.shared.configClientId = viewModel.clientId
        
        // Set the address of the backend, the environement and the timeout
        InnovationEngine.shared.configLoaderServer = viewModel.loaderServer
        InnovationEngine.shared.configEnvironment = viewModel.environment
        InnovationEngine.shared.configTimeout = Int(viewModel.timeout) ?? 500
        
        
        // Setup specific fonts to be used:
        
        // The first font added is used as the default one for the <body> element of the Experiments' HTML.
        // Using "Segoe Print" here to highlight the purpose of this configuration.
        InnovationEngine.shared.addFont(familyName: "Segoe Print",
                                        fileContent: readBytes(for: "segoepr"))
        
        // Further fonts can be referred to as `font-family` CSS properties in the Experiments' HTML.
        // - muliregular
        InnovationEngine.shared.addFont(familyName: Fonts.muliRegular.fontName,
                                        fileContent: readBytes(for: Fonts.muliRegular.fileName))
        // - mulibold
        // When specifying different styles or weights, you can use the same familyName.
        InnovationEngine.shared.addFont(familyName: Fonts.muliBold.fontName,
                                        fileContent: readBytes(for: Fonts.muliBold.fileName),
                                        descriptors: ["weight": "700"])
        // - isidora semibold
        InnovationEngine.shared.addFont(familyName: Fonts.isidoraSemibold.fontName,
                                        fileContent: readBytes(for: Fonts.isidoraSemibold.fileName),
                                        descriptors: ["weight": "600", "style": "normal"])
    }

    private func handleError(_ error: Error) {
        var errorMessage = ""
        switch error as? RequestError {
        case .error(let error):
            errorMessage = error.localizedDescription
        case .parsing:
            errorMessage = "InnovationEngine parsing failed"
        case .webPageEmpty:
            errorMessage = "InnovationEngine web page is empty"
        case .none:
            fatalError("InnovationEngine request failed \n error in wrong format")
        }
        DispatchQueue.main.async {
            self.viewModel.setError(errorMessage)
            self.viewModel.setExperiment(nil)
        }
    }

    private func startExperiment(_ experiment: Experiment) {
        DispatchQueue.main.async {
            self.viewModel.setError("")
            self.viewModel.setExperiment(experiment)
            experiment.startWebView(on: self, with: [
                // the web view will cover the full screen
                "H:|-0-[w]-0-|",
                "V:|-0-[w]-0-|"]
            ) { [weak self] result in
                switch result {
                case .failure(let error):
                    // handle the error
                    self?.viewModel.setError(error.localizedDescription)

                case .success(let event):
                    // handle the event
                    print(event.experimentId!)
                    print(event.treatmentUuid!)
                    print(event.interaction!)
                    self?.viewModel.setCloseEvent(event)
                }
            }
        }
    }

    private func getExperiment() {
        /*
         Request the Experiments for the given screen ID.
         Screen IDs are considered as entry points.
         See getExperiments (plural) below for multiple screen IDs.
         */

        InnovationEngine.shared.getExperiment(
            screenId: viewModel.screenID
            /*
             For development purposes ONLY
             you can force the loading of a specific experiment
             by providing the "experimentId" parameter:
             */
//            , experimentId: "sHsq0RKX2Pl7F0kwfW1P"
            
            /*
             For development purposes ONLY
             you can force the loading of a specific treatment of the
             above specified experiment
             by providing the "treatmentUuid" parameter:
             */
//            , treatmentUuid: "6GDqzgBBpOkkBeIHJFcZSb"
            ) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.showLoading(shouldShow: false)
                }
                switch result {
                case .failure(let error):
                    // handle the error
                    self.handleError(error)
            
                case .success(let experiment):
                    // start the experiment
                    self.startExperiment(experiment)
                }
            }
    }

    private func getExperiments() {

        /*
         Request the Experiments for the given screen ID.
         Screen IDs are considered as entry points.
         Provide multiple screen IDs in a use case where you want to test
         various entry points (UI elements) on one screen.
         */

        InnovationEngine.shared.getExperiments(
            
            screenIds: [self.viewModel.screenID]
            
            /*
             For development purposes ONLY
             you can force the loading of a specific experiment
             by providing the "experimentId" parameter:
             */
//            , experimentId: "sHsq0RKX2Pl7F0kwfW1P"
            
            /*
             For development purposes ONLY
             you can force the loading of a specific treatment of the
             above specified experiment
             by providing the "treatmentUuid" parameter:
             */
//            , treatmentUuid: "6GDqzgBBpOkkBeIHJFcZSb"
            
            ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showLoading(shouldShow: false)
            }
            switch result {
            case .failure(let error):
                // handle the error
                self.handleError(error)

            case .success(let experiments):
                // This example only considers the first entry of the array of Experiments
                guard let experiment = experiments[0] else {
                    DispatchQueue.main.async {
                        self.viewModel.setError("No experiment returned")
                    }
                    return
                }
                // start the experiment
                self.startExperiment(experiment)
            }
        }
    }

    private func showLoading(shouldShow: Bool) {
        activityIndicator.isHidden = !shouldShow
        view.alpha = shouldShow ? 0.5 : 1.0
    }

    private func readBytes(for fontName: String) -> [UInt8] {
        var bytes = [UInt8]()
        if let filePath = Bundle.main.url(forResource: fontName, withExtension: "woff")?.path, let data = NSData(contentsOfFile: filePath) {
            var buffer: [UInt8] = Array(repeating: 0, count: data.length)
            data.getBytes(&buffer, length: data.length)
            bytes = buffer
        }
        return bytes
    }
}

// MARK: - UITableViewDelegate && UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        switch item.type {
        case .url, .environment, .timeout:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: BasicTableViewCell.defaultReuseIdentifier,
                for: indexPath
            ) as? BasicTableViewCell else { return UITableViewCell() }
            cell.setup(title: item.type.title, text: item.title)
            cell.applyAlignment(.natural)
            return cell
            
        case .result:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: BasicTableViewCell.defaultReuseIdentifier,
                for: indexPath
            ) as? BasicTableViewCell else { return UITableViewCell() }
            cell.setup(title: item.type.title, text: item.title)
            cell.applyAlignment()
            return cell
            
        case .clientID:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ClientIDTableViewCell.defaultReuseIdentifier,
                for: indexPath
            ) as? ClientIDTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            cell.setup(title: item.type.title, text: item.title)
            return cell
            
        case .screenID:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ScreenIDTableViewCell.defaultReuseIdentifier,
                for: indexPath
            ) as? ScreenIDTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            cell.setup(with: item.title)
            return cell
        }
    }
}

// MARK: - Presenter

extension ViewController: Presenter {
    func reloadData() {
        updateTableViewDataSource()
        setupEngine()
    }
}

// MARK: - ScreenIDTableViewCellProtocol

extension ViewController: ScreenIDTableViewCellProtocol {
    func didEndEditing(screenId: String) {
        viewModel.setScreenId(screenId)
    }
}

// MARK: - ClientIDTableViewCellProtocol

extension ViewController: ClientIDTableViewCellProtocol {
    func didTapRestartMultipleButton() {
        view.endEditing(true)
        viewModel.regenerateClientID()
        showLoading(shouldShow: true)
        getExperiments()
    }

    func didTapRestartButton() {
        view.endEditing(true)
        viewModel.regenerateClientID()
        showLoading(shouldShow: true)
        getExperiment()
    }
}
