import UIKit

protocol OrientationalProtocol { }

extension OrientationalProtocol {
    
    // MARK: - Methods
    func setSupportedOrientations(_ orientations: UIInterfaceOrientationMask) {
        AppConfigService.shared.supportedOrientations = orientations
    }
    
    func setOrientation(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
