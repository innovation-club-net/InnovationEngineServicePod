import Foundation
import InnovationEngineService
import UIKit

// swiftlint:disable line_length
class ViewModel {
    private(set) var clientId = Date().currentTimeMillis()
    private(set) var loaderServer: String = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_LOADER_SERVER") as! String
    private(set) var environment: String = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_ENVIRONMENT") as! String
    private(set) var timeout: String = Bundle.main.object(forInfoDictionaryKey: "NVTNCLB_TIMEOUT") as! String
    private(set) var screenID: String = "dashboard"
    private(set) var experiment: Experiment?
    private(set) var closeEvent: CloseEvent?
    private(set) var error: String = ""
    weak var presenter: Presenter?

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
        presenter?.reloadData()
    }

    func setCloseEvent(_ event: CloseEvent) {
        self.closeEvent = event
        presenter?.reloadData()
    }
}
