import UIKit
import Firebase
import ApphudSDK
import FirebaseRemoteConfig

public enum RemoteConfigKey: String {
    case Xtime_HA_PT_2_pw_default_ob_1 = "Xtime_HA_PT_2_pw_default_ob_1" // Затримка хрестика на пейволі з об (1 план)
    case Xtime_HA_PT_2_pw_default_inapp_1 = "Xtime_HA_PT_2_pw_default_inapp_1" // Затримка хрестика на пейволі інапному
    case Xtime_HA_PT_2_pw_special_inapp_1 = "Xtime_HA_PT_2_pw_special_inapp_1" // Затримка хретика на пейволі спешл
    case Paywall_visual_HA_PT_1_ob = "Paywall_visual_HA_PT_1_ob" // Який пейвол показувати після об
}

public struct RemoteConfigValues {
    enum Paywall: String {
        case pw_default_ob_1 = "pw_default_ob_1"
        case pw_default_inapp_1 = "pw_default_inapp_1"
        case pw_special_inapp_1 = "pw_special_inapp_1"
    }
}

final class BFirebaseServices: DIServicProtocols {
    public var remoteConfig: RemoteConfig!
    // MARK: - DIServicProtocols
    @MainActor
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        FirebaseApp.configure()
        
        Apphud.setDelegate(self)
        
        Analytics.setUserID(Apphud.userID())
        if let instanceID = Analytics.appInstanceID() {
            Apphud.addAttribution(data: nil, from: .firebase, identifer: instanceID,  callback: nil)
        }
        
        activateFirebaseRemoteConfig()
    }
    
    private func activateFirebaseRemoteConfig() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { (activated, error) in
                    if let error = error {
                        print("Activation error: \(error.localizedDescription)")
                    } else if activated {
                        print("✅ Config activated!")
                        
                        print("❗ RemoteConfigValue: key - \(RemoteConfigKey.Xtime_HA_PT_2_pw_default_ob_1.rawValue), value - \(self.remoteConfig.configValue(forKey: RemoteConfigKey.Xtime_HA_PT_2_pw_default_ob_1.rawValue).numberValue)")
                        print("❗ RemoteConfigValue: key - \(RemoteConfigKey.Xtime_HA_PT_2_pw_default_inapp_1.rawValue), value - \(self.remoteConfig.configValue(forKey: RemoteConfigKey.Xtime_HA_PT_2_pw_default_inapp_1.rawValue).numberValue)")
                        print("❗ RemoteConfigValue: key - \(RemoteConfigKey.Xtime_HA_PT_2_pw_special_inapp_1.rawValue), value - \(self.remoteConfig.configValue(forKey: RemoteConfigKey.Xtime_HA_PT_2_pw_special_inapp_1.rawValue).numberValue)")
                        print("❗ RemoteConfigValue: key - \(RemoteConfigKey.Paywall_visual_HA_PT_1_ob.rawValue), value - \(self.remoteConfig.configValue(forKey: RemoteConfigKey.Paywall_visual_HA_PT_1_ob.rawValue).stringValue ?? "Empty value")")
                    }
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
}

// MARK: - ApphudDelegate
extension BFirebaseServices: ApphudDelegate {
    
    func apphudDidChangeUserID(_ userID: String) {
        Analytics.setUserID(userID)
    }
}

