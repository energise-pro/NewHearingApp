import Foundation
import StoreKit
import ApphudSDK

struct AppSettings {
    
    // MARK: - Properties
    var appLaunchCount: Int {
        return UserDefaults.standard.integer(forKey: Constants.Keys.launchCount)
    }
    
    @Storage(key: "outputLanguageSetted", defaultValue: false)
    var outputLanguageSetted: Bool
    
    @Storage(key: "mainScreenKey", defaultValue: 0)
    var mainScreen: Int
    
    @Storage(key: "emailScreenShown", defaultValue: false)
    var emailScreenShown: Bool
    
    @Storage(key: "countOfPresentCrossPromo", defaultValue: 0)
    var countOfPresentCrossPromo: Int
    
    var userID: String {
        return Apphud.userID()
    }
    
    // MARK: - Internal Methods
    func incrementLaunchCount() {
        let newAppLaunchCount = appLaunchCount + 1
        UserDefaults.standard.set(newAppLaunchCount, forKey: Constants.Keys.launchCount)
        UserDefaults.standard.synchronize()
        
        if newAppLaunchCount > 1 {
            AppConfigService.shared.analytics.track(action: .v2AppOpen)
        } else {
            AppConfigService.shared.analytics.track(action: .v2FirstLaunch)
        }
        
        newAppLaunchCount % 5 == 0 ? presentAppRatingAlert() : Void()
        newAppLaunchCount % 5 == 0 ? presentCrossPromoIfNeeded() : Void()
    }
    
    func presentAppRatingAlert() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        SKStoreReviewController.requestReview(in: scene)
    }
    
    func presentCrossPromoIfNeeded() {
        guard countOfPresentCrossPromo < 2 else {
            return
        }
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            NavigationManager.shared.presentCrossPromoViewController()
            AppConfigService.shared.settings.countOfPresentCrossPromo += 1
        }
    }
}
