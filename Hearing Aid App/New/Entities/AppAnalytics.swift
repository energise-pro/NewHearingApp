import Foundation

struct AppAnalytics: IAnalyticsProtocol {
    
    static let TAG = "AppAnalytics"
    
    private var services: [IAnalyticsService]
    
    init(services: [IAnalyticsService]) {
        self.services = services
    }
    
    // MARK: - IAnalyticsProtocol
    func trackTrial(amount: Double, currency: String) {
        Logger.log(tag: AppAnalytics.TAG, message: "Did track analytics trial with amount - \(amount), and currency - \(currency)")
        services.forEach { $0.trackTrial(amount: amount, currency: currency) }
    }
    
    func track(_ action: AnalyticsAction, with fillingInfo: [String: Any]?) {
        Logger.log(tag: AppAnalytics.TAG, message: "Did track analytics action - \(action.rawValue), with fillingInfo - \(fillingInfo ?? [:])")
        services.forEach { $0.track(action, with: fillingInfo) }
    }
}
