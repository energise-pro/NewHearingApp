import Foundation

struct FAppinAnalytica: FIAnalyticProtocols {
    
    static let TAG = "FAppinAnalytica"
    
    private var services: [IAnalyticsService]
    
    init(services: [IAnalyticsService]) {
        self.services = services
    }
    
    // MARK: - FIAnalyticProtocols
    func trackTrial(amount: Double, currency: String) {
        LoggerApp.log(tag: FAppinAnalytica.TAG, message: "Did track analytics trial with amount - \(amount), and currency - \(currency)")
        services.forEach { $0.trackTrial(amount: amount, currency: currency) }
    }
    
    func track(_ action: GAppAnalyticActions, with fillingInfo: [String: Any]?) {
        LoggerApp.log(tag: FAppinAnalytica.TAG, message: "Did track analytics action - \(action.rawValue), with fillingInfo - \(fillingInfo ?? [:])")
        services.forEach { $0.track(action, with: fillingInfo) }
    }
}
