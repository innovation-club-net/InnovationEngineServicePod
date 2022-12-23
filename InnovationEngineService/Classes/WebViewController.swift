import UIKit
import WebKit

// swiftlint:disable all
@available(iOS 13.0, *)
class WebViewViewController: UIViewController {
    var webView = WKWebView()
    private let loadingView = UIView()

    private var experiment: Experiment?
    private var visualFormatConstraints: [String]?
    private var completion: (Result<CloseEvent, Error>) -> Void

    init(experiment: Experiment, visualFormatConstraints: [String]? = nil, completion: @escaping (Result<CloseEvent, Error>) -> Void) {
        self.experiment = experiment
        self.visualFormatConstraints = visualFormatConstraints
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupWebView()
        addSubviews()
        setupConstrains()
        setupTapGestureToView()
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        let contentController = webConfiguration.userContentController
        contentController.add(self, name: JSCommand.closeWebView.rawValue)
        contentController.add(self, name: JSCommand.setFonts.rawValue)
        
        webView.isOpaque = false
        webView.backgroundColor = .white.withAlphaComponent(0.75)
        webView.scrollView.backgroundColor = .clear
        
        self.webView = webView
    }

    private func addSubviews() {
        view.addSubview(webView)
    }

    private func setupConstrains() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        guard let visualFormatConstraints = visualFormatConstraints, !visualFormatConstraints.isEmpty else {
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            return
        }
        var allConstraints = [NSLayoutConstraint]()
        visualFormatConstraints.forEach { visualFormat in
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: visualFormat, metrics: nil, views: ["w": webView])
            allConstraints.append(contentsOf: constraints)
        }
        NSLayoutConstraint.activate(allConstraints)
    }
    
    private func setupTapGestureToView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    private func handleCloseEvent(_ messageValue: String) {
        let jsonData = Data(messageValue.utf8)
        do {
            let closeEvent = try JSONDecoder().decode(CloseEvent.self, from: jsonData)
            completion(.success(closeEvent))
        } catch let error {
            completion(.failure(error))
        }
        dismiss(animated: false)
    }
    
    private func handleFontAction(_ message: WKScriptMessage) {
        if let message = message.body as? String, message == JSCommand.setFonts.rawValue {
            guard let fontAssetsJson = InnovationEngine.shared.fontAssetsJson() else { return }
            let script = "addFontAssets(\(fontAssetsJson))"
            webView.evaluateJavaScript(script) { _, error in
                if error == nil {
//                    print("Fonts injected\n")
                } else {
                    print("Fonts injection failed: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: false)
    }
}

// MARK: - WKNavigationDelegate

@available(iOS 13.0, *)
extension WebViewViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webView.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: webView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
        ])
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.removeFromSuperview()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingView.removeFromSuperview()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           navigationAction.navigationType == .linkActivated,
           url.scheme != webView.url?.scheme || url.host != webView.url?.host {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}

// MARK: - WKScriptMessageHandler

@available(iOS 13.0, *)
extension WebViewViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageDictionary = message.body as? [String: String],
           let messageValue = messageDictionary[JSCommand.closeWebView.rawValue] {
            handleCloseEvent(messageValue)
        } else {
            handleFontAction(message)
        }
    }
}
