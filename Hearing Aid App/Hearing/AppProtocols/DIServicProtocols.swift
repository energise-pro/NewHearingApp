import UIKit

typealias IAnalyticsService = DIServicProtocols & FIAnalyticProtocols

protocol DIServicProtocols {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    
    func applicationDidBecomeActive(_ application: UIApplication)
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    
    @discardableResult
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    
    func applicationWillEnterForeground(_ application: UIApplication)
    
    func applicationDidEnterBackground(_ application: UIApplication)
}

extension DIServicProtocols {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) { }
    
    func applicationDidBecomeActive(_ application: UIApplication) { }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) { }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) { }
    
    @discardableResult
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) { }
    
    func applicationDidEnterBackground(_ application: UIApplication) { }
}
