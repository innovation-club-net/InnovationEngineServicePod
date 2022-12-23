import Foundation
import WebKit

// swiftlint:disable line_length
public class Experiment {
    public var getWebViewHtml: String? {
        return webViewHtml
    }

    private let webViewHtml: String
    private let baseURL: URL?

    init(webViewHtml: String, baseURL: URL?) {
        self.webViewHtml = webViewHtml
        self.baseURL = baseURL
    }

    /// Creates a 'WebView' and runs the experiment inside of it
    /// Upon Completion  it handles experimentResult as 'CloseEvent' passed to Experiment instance
    ///
    /// - Parameter viewController: viewController inside which the experiment will run
    /// - Parameter visualFormatConstraints: the layout constraints used to position the webView
    /// - Parameter completion: the callback called upon the completion of the experiment
    ///
    public func startWebView(on viewController: UIViewController, with visualFormatConstraints: [String], completion: @escaping (Result<CloseEvent, Error>) -> Void) {
        let webViewController = WebViewViewController(experiment: self, visualFormatConstraints: visualFormatConstraints, completion: completion)
        webViewController.modalPresentationStyle = .overCurrentContext
        viewController.present(webViewController, animated: false)
        webViewController.webView.loadHTMLString(webViewHtml, baseURL: baseURL)
    }
}

struct ExperimentData: Codable {
    var url: String
    var html: String?
}
