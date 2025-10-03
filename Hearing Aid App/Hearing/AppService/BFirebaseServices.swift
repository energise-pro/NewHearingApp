import UIKit
import Firebase
import ApphudSDK
import FirebaseRemoteConfig

public enum RemoteConfigKey: String {
    case Xtime_HA_PT_2_pw_default_ob_1 = "Xtime_HA_PT_2_pw_default_ob_1" // Затримка хрестика на пейволі з об (1 план)
    case Xtime_HA_PT_2_pw_default_inapp_1 = "Xtime_HA_PT_2_pw_default_inapp_1" // Затримка хрестика на пейволі інапному
    case Xtime_HA_PT_2_pw_special_inapp_1 = "Xtime_HA_PT_2_pw_special_inapp_1" // Затримка хретика на пейволі спешл
    case Paywall_visual_HA_PT_1_ob = "Paywall_visual_HA_PT_1_ob" // Який пейвол показувати після об
    case Price_HA_PT_2_pw_default_ob_1 = "Price_HA_PT_2_pw_default_ob_1" // Ціни на пейволі з об (1 план) через плейсменти апхуда
    case Price_HA_PT_2_pw_default_inapp_1 = "Price_HA_PT_2_pw_default_inapp_1" // Ціни на пейволі інапному через плейсменти апхуда
    case Price_HA_PT_2_pw_special_inapp_1 = "Price_HA_PT_2_pw_special_inapp_1" // Ціни на пейволі спешл через плейсменти апхуда
    case Price_HA_PT_5_pw_inapp_monthly = "Price_HA_PT_5_pw_inapp_monthly"
    case Price_HA_PT_5_pw_special_monthly = "Price_HA_PT_5_pw_special_monthly"
    case Paywall_visual_inapp = "Paywall_visual_inapp"
    case Paywall_visual_special = "Paywall_visual_special"
    case Paywall_visual_product_perDay_inapp = "Paywall_visual_product_perDay_inapp"
    case Paywall_visual_product_perDay_special = "Paywall_visual_product_perDay_special"
    case Push_special_close = "Push_special_close"
}

public struct RemoteConfigValues {
    enum Paywall: String {
        case pw_default_ob_1 = "pw_default_ob_1"
        case pw_default_inapp_1 = "pw_default_inapp_1"
        case pw_special_inapp_1 = "pw_special_inapp_1"
        case pw_inapp_monthly = "pw_inapp_monthly"
        case pw_special_monthly = "pw_special_monthly"
    }
}

private enum RemoteValueType {
    case string
    case int
    case bool
}

private struct RemoteValueDescriptor {
    let key: RemoteConfigKey
    let type: RemoteValueType
}

final class BFirebaseServices: DIServicProtocols {
    public var remoteConfig: RemoteConfig!
    private let remoteValueDescriptors: [RemoteValueDescriptor] = [
        .init(key: .Xtime_HA_PT_2_pw_default_ob_1, type: .int),
        .init(key: .Xtime_HA_PT_2_pw_default_inapp_1, type: .int),
        .init(key: .Xtime_HA_PT_2_pw_special_inapp_1, type: .int),
        .init(key: .Paywall_visual_HA_PT_1_ob, type: .string),
        .init(key: .Price_HA_PT_2_pw_default_ob_1, type: .string),
        .init(key: .Price_HA_PT_2_pw_default_inapp_1, type: .string),
        .init(key: .Price_HA_PT_2_pw_special_inapp_1, type: .string),
        .init(key: .Price_HA_PT_5_pw_inapp_monthly, type: .string),
        .init(key: .Price_HA_PT_5_pw_special_monthly, type: .string),
        .init(key: .Paywall_visual_inapp, type: .string),
        .init(key: .Paywall_visual_special, type: .string),
        .init(key: .Paywall_visual_product_perDay_inapp, type: .bool),
        .init(key: .Paywall_visual_product_perDay_special, type: .bool),
        .init(key: .Push_special_close, type: .bool)
    ]
    // MARK: - DIServicProtocols
    @MainActor
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        FirebaseApp.configure()
        
        Apphud.setDelegate(self)
        
        Analytics.setUserID(Apphud.userID())
        if let instanceID = Analytics.appInstanceID() {
            Apphud.setAttribution(data: nil, from: .firebase, identifer: instanceID,  callback: nil)
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
                        KAppConfigServic.shared.analytics.track(.remoteConfigActivatedError, with: ["description": "\(error.localizedDescription)"])
                    } else if activated {
                        print("✅ Config activated!")
                        for descriptor in self.remoteValueDescriptors where self.hasRemoteConfigValue(forKey: descriptor.key) {
                            let value: String
                            switch descriptor.type {
                            case .string:
                                value = self.getStringValue(forKey: descriptor.key)
                            case .int:
                                value = "\(self.getIntValue(forKey: descriptor.key))"
                            case .bool:
                                value = "\(self.getBoolValue(forKey: descriptor.key))"
                            }
                            print("‼️ Config activated: \(descriptor.key.rawValue) - \(value)")
                        }
                        self.sendActionAfterRemoteConfigActivated()
                    }
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
                KAppConfigServic.shared.analytics.track(.remoteConfigActivatedError, with: ["description": "\(error?.localizedDescription ?? "No error available.")"])
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

// MARK: - BFirebaseServices extension
extension BFirebaseServices {
    
    public func getRemoteConfigValue(forKey key: RemoteConfigKey) -> RemoteConfigValue {
        return remoteConfig.configValue(forKey: key.rawValue)
    }

    public func getStringValue(forKey key: RemoteConfigKey) -> String {
        return remoteConfig.configValue(forKey: key.rawValue).stringValue ?? ""
    }
    
    public func getBoolValue(forKey key: RemoteConfigKey) -> Bool {
        return remoteConfig.configValue(forKey: key.rawValue).boolValue
    }
    
    public func getIntValue(forKey key: RemoteConfigKey) -> Int {
        return Int(truncating: self.remoteConfig.configValue(forKey: key.rawValue).numberValue)
    }
    
    private func sendActionAfterRemoteConfigActivated() {
        var additionalInfo: [String: String] = [:]
        
        for descriptor in remoteValueDescriptors where hasRemoteConfigValue(forKey: descriptor.key) {
            let value: String
            switch descriptor.type {
            case .string:
                value = getStringValue(forKey: descriptor.key)
            case .int:
                value = "\(getIntValue(forKey: descriptor.key))"
            case .bool:
                value = "\(getBoolValue(forKey: descriptor.key))"
            }
            additionalInfo[descriptor.key.rawValue] = value
        }

        KAppConfigServic.shared.analytics.track(.remoteConfigActivated, with: additionalInfo)
    }
    
    private func hasRemoteConfigValue(forKey key: RemoteConfigKey) -> Bool {
        let value = self.getRemoteConfigValue(forKey: key)
        return value.source != .static
    }
}

