import UIKit

final class AppConfigService: NSObject, IServiceProtocol {
    
    // MARK: - Properties
    static let shared: AppConfigService = AppConfigService()
    static let TAG = "AppConfigService"
    
    var analytics: AppAnalytics
    var settings: AppSettings
    var services: [IServiceProtocol]
    var supportedOrientations: UIInterfaceOrientationMask = .portrait
    
    private var asaService: ASAService
    private var oneSignalService: OneSignalService
    
    // MARK: - Methods
    override init() {
        let inAppPurchasesService = InAppPurchasesService(apiKey: Constants.General.appHudKey)
        oneSignalService = OneSignalService(apiKey: Constants.General.oneSignalKey)
        let services: [IServiceProtocol] = [inAppPurchasesService, FirebaseService(), oneSignalService, AmplitudeService(apiKey: Constants.General.amplitudeKey), BranchService(), FacebookService()]
        self.services = services
        
        let analyticsServices = services.compactMap { ($0 as? IAnalyticsService) }
        self.analytics = AppAnalytics(services: analyticsServices)
        self.settings = AppSettings()
        self.asaService = ASAService()
        
        supportedOrientations = UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
    }
    
    func app(_ application: UIApplication, didFinishLaunch launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        services.forEach { $0.application(application, didFinishLaunchingWithOptions: launchOptions) }
        settings.incrementLaunchCount()
        
        ThemeService.shared.initializeService()
        TranslateService.shared.prepareService()
        
        settings.appLaunchCount < 2 ? NavigationManager.shared.setFakeSplashAsRootViewController() : NavigationManager.shared.setTabBarAsRootViewController()
        
        asaService.initializeASATools()
        asaService.sendAppleAttribution()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        services.forEach { $0.applicationDidBecomeActive(application) }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) {
        services.forEach { $0.application(app, open: url, options: options) }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        services.forEach { $0.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler) }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        services.forEach { $0.application(application, continue: userActivity, restorationHandler: restorationHandler) }
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        services.forEach { $0.applicationWillEnterForeground(application) }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        services.forEach { $0.applicationDidEnterBackground(application) }
    }
    
    // MARK: - Internal methods
    func requestIDFA(completion: ASAServiceCompletion?) {
        asaService.requestIDFA(completion: completion)
    }
    
    func setUserEmail(_ email: String) {
        oneSignalService.setUserEmail(email)
    }
}
