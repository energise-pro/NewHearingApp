import UIKit
import OneSignal
import ApphudSDK

final class OneSignalService: NSObject, IServiceProtocol {
    
    static let TAG = "OneSignalService"
    
    // MARK: - Properties
    let apiKey: String
    
    // MARK: - Init
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - IServiceProtocol
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId(apiKey)
        OneSignal.setExternalUserId(Apphud.userID())
        
        Apphud.setDelegate(self)
        
        let userID = OneSignal.getDeviceState().userId
        Logger.log(tag: OneSignalService.TAG, message: "OneSignal userID = \(userID ?? "")")
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        if let data = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any],
           let notificationData = data["custom"] as? [String: Any] {
            processPushNotification(with: notificationData)
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        handleEventDeeplink(userActivity.webpageURL)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) {
        handleEventDeeplink(url)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        configureCatchUpPushNotification()
    }
    
    // MARK: - Internal methods
    func setUserEmail(_ email: String) {
        OneSignal.setEmail(email)
        
        OneSignal.setExternalUserId(Apphud.userID(), withSuccess: { results in
            if let emailResults = results?["email"] {
                print("Set external user id email status: ", emailResults)
            }
        }, withFailure: { error in
            print("Set external user id done with error: " + error.debugDescription)
        })
    }
    
    // MARK: - Private methods
    private func configureCatchUpPushNotification() {
        guard AppConfiguration.shared.settings.appLaunchCount < 2 && !InAppPurchasesService.shared.isPremium && UserDefaults.standard.bool(forKey: CAppConstants.Keys.wasConfiguredPushOffer) == false else {
            return
        }
        UserDefaults.standard.setValue(true, forKey: CAppConstants.Keys.wasConfiguredPushOffer)
        let calendar = Calendar.current
        let futureDate = Calendar.current.date(byAdding: .second, value: 5, to: Date()) ?? Date()
        let dateComponent = DateComponents(year: calendar.component(.year, from: futureDate), month: calendar.component(.month, from: futureDate), day: calendar.component(.day, from: futureDate), hour: calendar.component(.hour, from: futureDate), minute: calendar.component(.minute, from: futureDate), second: calendar.component(.second, from: futureDate))

        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "🥳85% Discount🥳".localized()
        notificationContent.body = "Don't miss your chance!".localized()
        notificationContent.userInfo["custom"] = ["a": ["open": CAppConstants.Keys.catchUpScreenName]]
        notificationContent.sound = UNNotificationSound.default

        let notificationCenter = UNUserNotificationCenter.current()
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(identifier: CAppConstants.Keys.catchUpScreenName, content: notificationContent, trigger: trigger)
        notificationCenter.add(request)
        Logger.log(tag: OneSignalService.TAG, message: "Catch Up reminder was successfully charged.")
    }
    
    private func handleEventDeeplink(_ url: URL?) {
        guard let url = url, let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let params = components.queryItems else {
            return
        }
        
        if let eventName = params.first(where: { $0.name == "eventName" })?.value {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                AppConfiguration.shared.analytics.track(GAppAnalyticActions.v2AppStoreEvent, with: [GAppAnalyticActions.event.rawValue: eventName])
            }
        }
        
        if let screenName = params.first(where: { $0.name == "screenName" })?.value {
            AppConfiguration.shared.analytics.track(GAppAnalyticActions.v2Deeplink, with: [GAppAnalyticActions.open.rawValue: screenName])
            openScreen(with: screenName, with: .openFromDeeplink)
        }
    }
    
    private func processPushNotification(with notificationData: [String: Any]) {
        guard let additionalData = notificationData["a"] as? [String: Any], let screenName = additionalData["open"] as? String else {
            return
        }
        AppConfiguration.shared.analytics.track(GAppAnalyticActions.v2Notification, with: [GAppAnalyticActions.open.rawValue: screenName])
        openScreen(with: screenName, with: .openFromNotification)
    }
    
    private func openScreen(with screenName: String, with openAction: GAppAnalyticActions) {
        switch screenName {
        case CAppConstants.Keys.paywallScreenName:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AppsNavManager.shared.presentPaywallViewController(with: openAction)
            }
        case CAppConstants.Keys.catchUpScreenName:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AppsNavManager.shared.presentSCatchUpApViewController()
            }
        default:
            break
        }
    }
}

// MARK: - ApphudDelegate
extension OneSignalService: ApphudDelegate {
    
    func apphudDidChangeUserID(_ userID: String) {
        OneSignal.setExternalUserId(Apphud.userID())
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension OneSignalService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        Logger.log(tag: OneSignalService.TAG, message: "Notification center will present notification with: \(userInfo)")
        completionHandler([.banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        Logger.log(tag: OneSignalService.TAG, message: "Notification did receive response with: \(userInfo)")
        if let notificationData = userInfo["custom"] as? [String: Any] {
            processPushNotification(with: notificationData)
        }
        completionHandler()
    }
}
