import UIKit

protocol AOrientationalApProtocol { }

extension AOrientationalApProtocol {
    
    // MARK: - Methods
    func setSupportedOrientations(_ orientations: UIInterfaceOrientationMask) {
        KAppConfigServic.shared.supportedOrientations = orientations
    }
    
    func setOrientation(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
