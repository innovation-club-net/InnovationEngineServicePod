import UIKit

public enum Environment: String {
    case prod
    case dev
    case test
}

public enum RequestError: Error {
    case error(Error)
    case parsing
    case webPageEmpty
}

// swiftlint:disable all
@available(iOS 13.0, *)
public class InnovationEngine {
    
    // MARK: - URL Session setup
    public static var shared: InnovationEngine = InnovationEngine()
    private lazy var sessionConfiguration = URLSessionConfiguration.default
    private lazy var urlSession = URLSession(configuration: sessionConfiguration)
    
    /// Instance of url for getting single Experiment
    private(set) var loaderUrl: String?
    
    /// Instance of url for getting multiple Experiments
    private(set) var experimentsUrl: String?
    
    /// Any kind of unique identifier for the user on this device
    public var configClientId: String?
    
    /// The address of your Innovation Engine instance
    public var configLoaderServer: String? {
        didSet { updateUrls() }
    }
    
    /// The logical environment from which experiments shall be retrieved
    public var configEnvironment: String? = Environment.prod.rawValue {
        didSet { updateUrls() }
    }
    
    /// The duration in miliseconds of the timeout
    public var configTimeout: Int = 500 {
        didSet {
            sessionConfiguration.timeoutIntervalForResource = TimeInterval(Double(self.configTimeout) / 1000)
        }
    }
    public var deepLinkPrefix: String?
    /// Returns an instance of Experiment if any is applicable for the given 'screenID' or returns Error
    /// Error can be received in the case of empty Experiment or excluded arbitrary trigger conditions
    ///
    ///     InnovationEngine.shared.getExperiment(screenId: "alert") { [weak self] result in
    ///         guard let self = self else { return }
    ///         DispatchQueue.main.async { self.showLoading(shouldShow: false) }
    ///         switch result {
    ///         case .failure(let error):
    ///             self.handleError(error)
    ///         case .success(let experiment):
    ///         // Start webview
    ///             self.startExperiment(experiment)
    ///     }
    ///
    /// - Parameter screenId: single element of arbitrary string identifying the screen or context
    /// - Parameter experimentId: (optional) forces a specific experiment to be returned. ONLY in combination with treatmendUuid
    /// - Parameter treatmentUuid: (optional) forces a specific treatment to be retutrned. ONLY in combination with ExperimentId
    /// - Parameter completion: returns a completion with the result of Experiment or some type of Error
    ///
    public func getExperiment(screenId: String,
                              experimentId: String? = nil,
                              treatmentUuid: String? = nil,
                              completion:  @escaping (Result<Experiment, Error>) -> Void) {
        guard let loaderUrl = loaderUrl,
              let url = URL(string: loaderUrl) else {
            fatalError()
        }
        var queryItems = [
            "nvtnclb-clientid": configClientId,
            "nvtnclb-screen": screenId
        ]
        
        if let experimentId = experimentId, let treatmentUuid = treatmentUuid {
            queryItems["nvtnclb-experiment"] = experimentId
            queryItems["nvtnclb-treatment"] = treatmentUuid
        }
        
        let urlWithQueryItems = setUpURLWithQueryItems(for: url, with: queryItems)
        
        urlSession.dataTask(with: urlWithQueryItems, completionHandler: { data, response, error in
            if let error = error { return completion(.failure(RequestError.error(error)) ) } // Handle error
            
            guard
                let data = data,
                let webviewHtml = String(data: data, encoding: .utf8)
            else { return completion(.failure(RequestError.parsing)) } // Parse web page from data
            
            if webviewHtml.isEmpty { return completion(.failure(RequestError.webPageEmpty)) } // If web page is empty
            
            let experiment = Experiment(webViewHtml: webviewHtml,
                                        baseURL: urlWithQueryItems) // Initiate WebViewController if everything in place
            completion(.success(experiment))
                
        }).resume()
    }
    
    /// Returns an Array of (Optional) Experiments if there are any applicable for the given 'screenIds'
    ///
    ///     InnovationEngine.shared.getExperiments(screenIds: ["multi", "alert"]) { [weak self] result in
    ///         guard let self = self else { return }
    ///         DispatchQueue.main.async { self.showLoading(shouldShow: false) }
    ///         switch result {
    ///         case .failure(let error):
    ///             self.handleError(error)
    ///         case .success(let experiments):
    ///         // Let's consider only the first experiment
    ///         // Check if experiment is nil
    ///             guard let experiment = experiments[0] else { return }
    ///             // start webview
    ///             self.startExperiment(experiment)
    ///         }
    ///       }
    ///
    /// - Parameter screenIds: array element of arbitrary strings identifying the screen or context
    /// - Parameter experimentId: (optional) forces a specific experiment to be returned. ONLY in combination with treatmentUuid
    /// - Parameter treatmentUuid: (optional) forces a specific treatment to be retutrned. ONLY in combination with ExperimentId
    /// - Parameter completion: returns an Array of Results of type (optional) Experiment or Error
    ///
    
    public func getExperiments(screenIds: [String],
                               experimentId: String? = nil,
                               treatmentUuid: String? = nil,
                               completion: @escaping (Result<[Experiment?], Error>) -> Void) {
        guard let experimentsUrl = experimentsUrl,
              let url = URL(string: experimentsUrl) else {
            fatalError()
        }
        
        var queryItems: [String: String?] = [:]
        if let experimentId = experimentId, let treatmentUuid = treatmentUuid {
            queryItems["nvtnclb-experiment"] = experimentId
            queryItems["nvtnclb-treatment"] = treatmentUuid
        }
        let urlWithQueryItems = setUpURLWithQueryItems(for: url, with: queryItems)
        
        guard let configClientId = configClientId else { return }
        let json: [String: Any] = ["clientId": configClientId,
                                   "screenIds": screenIds]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        var request = URLRequest(url: urlWithQueryItems)
        request.httpBody = jsonData
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        urlSession.dataTask(with: request, completionHandler: { data, response, error in
            if let error = error { return completion(.failure(RequestError.error(error)) ) } // Handle error
            guard let data = data,
                  let experimentsData = try? JSONDecoder().decode([ExperimentData].self, from: data) else { return completion(.failure(RequestError.parsing)) } // Parse experiments from data
            
            let experiments = experimentsData.map { experiment -> Experiment? in
                guard let html = experiment.html else { return nil }
                return Experiment(webViewHtml: html, baseURL: URL(string: experiment.url)) // Transforming data to Experiment
            }
            
            completion(.success(experiments))
        }).resume()
    }
    
    private var fontAssetKeys: Set<String> = []
    public var fontAssets: [FontAsset] = []
    
    
    /// Registers fonts into the Innovation Engine to make them available in the WebView as font families with optional specific style and weight
    public func addFont(familyName: String, fileContent: [UInt8], descriptors: [String: String]? = nil) {
        let fontAssetKey = familyName + jsonString(from: descriptors)
        guard !fontAssetKeys.contains(fontAssetKey) else { return }
        let base64String = Data(fileContent).base64EncodedString()
        let fontAsset = FontAsset(familyName: familyName, fileContentBase64: base64String, descriptors: descriptors)
        fontAssets.append(fontAsset)
        fontAssetKeys.insert(fontAssetKey)
    }
    
    public func fontAssetsJson() -> String? {
        return jsonString(from: fontAssets)
    }
    
    private func jsonString<T: Encodable>(from item: T) -> String {
        guard let jsonData = try? JSONEncoder().encode(item), let jsonString = String(data: jsonData, encoding: .utf8) else { fatalError() }
         return jsonString
     }
}

@available(iOS 13.0, *)
extension InnovationEngine {
    private func setUpURLWithQueryItems(for url: URL, with items: [String: String?]) -> URL {
        var url = url
        for (key, value) in items {
            if let value = value {
                url.appendQueryItem(key, value: value)
            }
        }
        return url
    }
    
    private func updateUrls() {
        let cacheBuster = NSDate().timeIntervalSince1970
        guard let configLoaderServer = configLoaderServer,
              let configEnvironment = configEnvironment else { fatalError() }
        loaderUrl = "\(configLoaderServer)/run/multi/v2/front/\(cacheBuster)/\(configEnvironment)/webview.html"
        experimentsUrl = "\(configLoaderServer)/run/multi/v2/front/\(cacheBuster)/\(configEnvironment)/webview.json"
    }
}

extension URL {
    mutating func appendQueryItem(_ name: String, value: String?) {
        guard var urlComponents = URLComponents(string: absoluteString) else { return }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: name, value: value)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        self = urlComponents.url!
    }
}
