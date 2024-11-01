import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppConfigService.shared.app(application, didFinishLaunch: launchOptions)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return AppConfigService.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppConfigService.shared.application(app, open: url, options: options)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppConfigService.shared.applicationDidBecomeActive(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        AppConfigService.shared.applicationWillEnterForeground(application)
        let topViewController = UIApplication.shared.topMostViewController()
        let viewControllers = [topViewController, window?.rootViewController].compactMap { $0 as? IAppStateListener }
        viewControllers.forEach { $0.appWillEnterForeground?() }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AppConfigService.shared.applicationDidEnterBackground(application)
        let topViewController = UIApplication.shared.topMostViewController()
        let viewControllers = [topViewController, window?.rootViewController].compactMap { $0 as? IAppStateListener }
        viewControllers.forEach { $0.appDidEnterBackground?() }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppConfigService.shared.supportedOrientations
    }
}
