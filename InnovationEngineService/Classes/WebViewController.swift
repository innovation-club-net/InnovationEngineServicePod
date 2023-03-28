import UIKit
import WebKit

// swiftlint:disable all
@available(iOS 13.0, *)
class WebViewViewController: UIViewController {
    var webView: WKWebView?

    private var experiment: Experiment?
    
    private var completion: (Result<CloseEvent, Error>) -> Void
        

    init(experiment: Experiment, completion: @escaping (Result<CloseEvent, Error>) -> Void) {
        self.experiment = experiment
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }

    
    override func viewDidLayoutSubviews() {
        if let webView = webView {
            webView.frame = view.bounds
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        webView?.removeFromSuperview()
        webView = nil
        experiment = nil
        super.viewWillDisappear(animated)
    }

    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        let contentController = webConfiguration.userContentController
        contentController.add(self, name: JSCommand.closeWebView.rawValue)
        contentController.add(self, name: JSCommand.setFonts.rawValue)

        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear

        self.webView = webView
        
        view.addSubview(webView)
    }
    

    
    private func handleCloseEvent(_ messageValue: String) {
        closeWebView()

        let jsonData = Data(messageValue.utf8)
        do {
            let closeEvent = try JSONDecoder().decode(CloseEvent.self, from: jsonData)
            completion(.success(closeEvent))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    private func handleFontAction(_ message: WKScriptMessage) {
        if let message = message.body as? String, message == JSCommand.setFonts.rawValue {
            guard let fontAssetsJson = InnovationEngine.shared.fontAssetsJson() else { return }
            let script = "addFontAssets(\(fontAssetsJson))"
            webView?.evaluateJavaScript(script) { _, error in
                if error == nil {
//                    print("Fonts injected\n")
                } else {
                    print("Fonts injection failed: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    

    
    override func viewDidDisappear(_ animated: Bool) {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: JSCommand.closeWebView.rawValue)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: JSCommand.setFonts.rawValue)
        webView?.navigationDelegate = nil
    }
    
    private func closeWebView() {
        view.removeFromSuperview()
    }
}

// MARK: - WKNavigationDelegate

@available(iOS 13.0, *)
extension WebViewViewController: WKNavigationDelegate {

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
