import Foundation
import InnovationEngineService
import UIKit

// swiftlint:disable line_length
class ViewModel {
    private(set) var clientId = Date().currentTimeMillis()
    private(set) var loaderServer: String
    private(set) var environment: String
    private(set) var timeout: String
    private(set) var screenID: String
    private(set) var experiment: Experiment?
    private(set) var closeEvent: CloseEvent?
    private(set) var error: String = ""
    weak var presenter: Presenter?
    
    
    ///
    /// Initialise our model with values from the `InnovationEngineConfig.xcconfig` file
    /// or with fallback values
    ///
    init() {
        clientId = Date().currentTimeMillis()
        
        let loaderServer = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_LOADER_SERVER") as? String ?? ""
        self.loaderServer = !loaderServer.isEmpty ? loaderServer : "https://your-instance.innovation-club.net"
        
        let environment = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_ENVIRONMENT") as? String ?? ""
        self.environment = !environment.isEmpty ? environment : "test"
        
        let timeout = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_TIMEOUT") as? String ?? ""
        self.timeout = !timeout.isEmpty ? timeout : "500"
        
        let sampleScreenId = Bundle.main.object(forInfoDictionaryKey: "SAMPLE_SCREEN_ID") as? String ?? ""
        screenID = !sampleScreenId.isEmpty ? sampleScreenId : "demo"
    }

    func regenerateClientID() {
        self.clientId = Date().currentTimeMillis()
        presenter?.reloadData()
    }

    func setScreenId(_ screenId: String) {
        self.screenID = screenId
        presenter?.reloadData()
    }

    func setExperiment(_ experiment: Experiment?) {
        self.experiment = experiment
        presenter?.reloadData()
    }

    func setError(_ error: String) {
        self.error = error
        self.closeEvent = nil
        presenter?.reloadData()
    }

    func setCloseEvent(_ event: CloseEvent) {
        self.closeEvent = event
        presenter?.reloadData()
    }
}
