import UIKit
import Amplitude
import ApphudSDK

final class HAmplitudeApService: IAnalyticsService {
    
    static let TAG = "HAmplitudeApService"
    
    // MARK: - Properties
    private let apiKey: String
    
    // MARK: - Init
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - DIServicProtocols
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().setUserId(Apphud.userID())
        Amplitude.instance().useDynamicConfig = true
        
        Apphud.setDelegate(self)
    }
    
    // MARK: - FIAnalyticProtocols
    func track(_ action: GAppAnalyticActions, with fillingInfo: [String: Any]?) {
        #if DEBUG
        LoggerApp.log(tag: HAmplitudeApService.TAG, message: "Action - \(action.rawValue) with fillingInfo \(fillingInfo ?? [:]).")
        #else
        Amplitude.instance().logEvent(action.rawValue, withEventProperties: fillingInfo)
        #endif
    }
    
    func setUserProperty(with fillingInfo: [String: Any]?) {
        guard let fillingInfo = fillingInfo, !fillingInfo.isEmpty else {
            return
        }
        Amplitude.instance().setUserProperties(fillingInfo)
    }
}

// MARK: - ApphudDelegate
extension HAmplitudeApService: ApphudDelegate {
    
    func apphudDidChangeUserID(_ userID: String) {
        Amplitude.instance().setUserId(userID)
    }
}
