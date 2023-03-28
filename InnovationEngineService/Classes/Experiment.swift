import Foundation
import WebKit

// swiftlint:disable line_length
public class Experiment {
    public var getWebViewHtml: String? {
        return webViewHtml
    }

    private let webViewHtml: String
    private let baseURL: URL?

    private var webViewController: WebViewViewController?

    init(webViewHtml: String, baseURL: URL?) {
        self.webViewHtml = webViewHtml
        self.baseURL = baseURL
    }

    
    /// Creates a 'WebView' to run the experiment. Adds this webview inside the given `parentView`.
    /// Upon Completion  it handles experimentResult as 'CloseEvent' passed to Experiment instance
    ///
    /// - Parameter parentView: UIView inside which the experiment will run
    /// - Parameter completion: the callback called upon the completion of the experiment
    ///
    public func startWebView(inside parentView: UIView, completion: @escaping (Result<CloseEvent, Error>) -> Void) {

        webViewController?.view.removeFromSuperview()

        let webViewController = WebViewViewController(experiment: self, completion: completion)
        self.webViewController = webViewController
        parentView.addSubview(webViewController.view)
        setupConstrains(parentView: parentView, targetView: webViewController.view, visualFormatConstraints: nil)
        webViewController.webView?.loadHTMLString(webViewHtml, baseURL: baseURL)
    }
    
    
    private func setupConstrains(parentView: UIView, targetView: UIView?, visualFormatConstraints: [String]? = nil) {
        guard let targetView = targetView else {
            return
        }
        targetView.translatesAutoresizingMaskIntoConstraints = false
        guard let visualFormatConstraints = visualFormatConstraints, !visualFormatConstraints.isEmpty else {
            NSLayoutConstraint.activate([
                targetView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
                targetView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                targetView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                targetView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
            ])
            return
        }
        var allConstraints = [NSLayoutConstraint]()
        visualFormatConstraints.forEach { visualFormat in
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: visualFormat, metrics: nil, views: ["webview": targetView as Any])
            allConstraints.append(contentsOf: constraints)
        }
        NSLayoutConstraint.activate(allConstraints)
    }

}

struct ExperimentData: Codable {
    var url: String
    var html: String?
}
