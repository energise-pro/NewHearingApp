import UIKit
import Amplitude
import ApphudSDK

final class AmplitudeService: IAnalyticsService {
    
    static let TAG = "AmplitudeService"
    
    // MARK: - Properties
    private let apiKey: String
    
    // MARK: - Init
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - IServiceProtocol
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Amplitude.instance().initializeApiKey(apiKey)
        Amplitude.instance().setUserId(Apphud.userID())
        Amplitude.instance().useDynamicConfig = true
        
        Apphud.setDelegate(self)
    }
    
    // MARK: - IAnalyticsProtocol
    func track(_ action: GAppAnalyticActions, with fillingInfo: [String: Any]?) {
        #if DEBUG
        Logger.log(tag: AmplitudeService.TAG, message: "Action - \(action.rawValue) with fillingInfo \(fillingInfo ?? [:]).")
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
extension AmplitudeService: ApphudDelegate {
    
    func apphudDidChangeUserID(_ userID: String) {
        Amplitude.instance().setUserId(userID)
    }
}
