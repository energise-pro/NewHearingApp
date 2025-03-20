import UIKit
import AmplitudeSwift
import ApphudSDK

final class HAmplitudeApService: IAnalyticsService {
    
    static let TAG = "HAmplitudeApService"
    
    // MARK: - Properties
    private let apiKey: String
    private let amplitude: Amplitude
    
    // MARK: - Init
    init(apiKey: String) {
        self.apiKey = apiKey
        self.amplitude = Amplitude(configuration: Configuration(
            apiKey: apiKey,
            autocapture: [.sessions, .screenViews, .appLifecycles, .screenViews]
        ))
    }
    
    // MARK: - DIServicProtocols
    @MainActor
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        amplitude.setUserId(userId: Apphud.userID())
        Apphud.setDelegate(self)
    }
    
    // MARK: - FIAnalyticProtocols
    func track(_ action: GAppAnalyticActions, with fillingInfo: [String: Any]?) {
        #if DEBUG
        LoggerApp.log(tag: HAmplitudeApService.TAG, message: "Action - \(action.rawValue) with fillingInfo \(fillingInfo ?? [:]).")
        #else
        amplitude.track(
            eventType: action.rawValue,
            eventProperties: fillingInfo
        )
        #endif
    }
    
    func setUserProperty(with fillingInfo: [String: Any]?) {
        guard let fillingInfo = fillingInfo, !fillingInfo.isEmpty else {
            return
        }
        amplitude.identify(userProperties: fillingInfo)
    }
}

// MARK: - ApphudDelegate
extension HAmplitudeApService: ApphudDelegate {
    
    func apphudDidChangeUserID(_ userID: String) {
        amplitude.setUserId(userId: userID)
    }
}
