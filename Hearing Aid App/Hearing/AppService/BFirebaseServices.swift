import UIKit
import Firebase
import ApphudSDK

final class BFirebaseServices: DIServicProtocols {
    
    // MARK: - DIServicProtocols
    @MainActor
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        FirebaseApp.configure()
        
        Apphud.setDelegate(self)
        
        Analytics.setUserID(Apphud.userID())
        if let instanceID = Analytics.appInstanceID() {
            Apphud.addAttribution(data: nil, from: .firebase, identifer: instanceID,  callback: nil)
        }
    }
}

// MARK: - ApphudDelegate
extension BFirebaseServices: ApphudDelegate {
    
    func apphudDidChangeUserID(_ userID: String) {
        Analytics.setUserID(userID)
    }
}

