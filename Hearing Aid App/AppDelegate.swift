import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
                window?.overrideUserInterfaceStyle = .light
        }
        KAppConfigServic.shared.app(application, didFinishLaunch: launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return KAppConfigServic.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        KAppConfigServic.shared.application(app, open: url, options: options)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        KAppConfigServic.shared.applicationDidBecomeActive(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        KAppConfigServic.shared.applicationWillEnterForeground(application)
        let topViewController = UIApplication.shared.topDAppViewController()
        let viewControllers = [topViewController, window?.rootViewController].compactMap { $0 as? SIAppStateListeners }
        viewControllers.forEach { $0.appWillEnterForeground?() }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        KAppConfigServic.shared.applicationDidEnterBackground(application)
        let topViewController = UIApplication.shared.topDAppViewController()
        let viewControllers = [topViewController, window?.rootViewController].compactMap { $0 as? SIAppStateListeners }
        viewControllers.forEach { $0.appDidEnterBackground?() }
        AppPushManager.shared.showLimitedTimeSpecialOfferNotificationWithIfNeed(completion: nil)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return KAppConfigServic.shared.supportedOrientations
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        KAppConfigServic.shared.analytics.track(
            action: .appClosed,
            with: [
                "hearing_status" : SAudioKitServicesAp.shared.isStartedMixer ? "activated" : "deativated"
            ]
        )
    }
}
