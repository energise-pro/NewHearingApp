import Foundation

protocol IAnalyticsProtocol {
    
    func trackTrial(amount: Double, currency: String)
    
    func track(_ action: GAppAnalyticActions, with fillingInfo: [String: Any]?)
    
    func setUserProperty(with fillingInfo: [String: Any]?)
}

extension IAnalyticsProtocol {

    func track(action: GAppAnalyticActions, with fillingInfo: [String: Any]? = nil) {
        self.track(action, with: fillingInfo)
    }
    
    func trackTrial(amount: Double, currency: String) { }
    
    func track(_ action: GAppAnalyticActions, with fillingInfo: [String: Any]?) { }
    
    func setUserProperty(with fillingInfo: [String: Any]?) { }
}


