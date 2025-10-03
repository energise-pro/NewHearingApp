import UIKit
import FirebaseRemoteConfig
import AdjustSdk
import ApphudSDK

final class KAppConfigServic: NSObject, DIServicProtocols {
    
    // MARK: - Properties
    static let shared: KAppConfigServic = KAppConfigServic()
    static let TAG = "KAppConfigServic"
    
    var analytics: FAppinAnalytica
    var firebaseServices = BFirebaseServices()
    var settings: АHearAppSett
    var services: [DIServicProtocols]
    var supportedOrientations: UIInterfaceOrientationMask = .portrait
    
    private var asaServiceAp: QAsaServiceAp
    
    // MARK: - Methods
    override init() {
        let TInAppService = TInAppService(apiKey: CAppConstants.General.appHudKey)
        let services: [DIServicProtocols] = [TInAppService, firebaseServices, HAmplitudeApService(apiKey: CAppConstants.General.amplitudeKey), SFbServices()]
        self.services = services
        
        let analyticsServices = services.compactMap { ($0 as? IAnalyticsService) }
        self.analytics = FAppinAnalytica(services: analyticsServices)
        self.settings = АHearAppSett()
        self.asaServiceAp = QAsaServiceAp()
        
        supportedOrientations = UIDevice.current.userInterfaceIdiom == .pad ? .all : .portrait
    }
    
    func app(_ application: UIApplication, didFinishLaunch launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        services.forEach { $0.application(application, didFinishLaunchingWithOptions: launchOptions) }
        settings.incrementLaunchCount()
        
        AThemeServicesAp.shared.initializeService()
        BTranslServicesNew.shared.prepareService()
        
        settings.appLaunchCount < 2 ? AppsNavManager.shared.setNewOnboardingAsRootViewController() : AppsNavManager.shared.setTabBarAsRootViewController()
        
        asaServiceAp.initializeASATools()
        asaServiceAp.initializeJaklinSDK()
        asaServiceAp.sendAppleAttribution()
        initializeAdjustSDK()
        
        // Add for HAD-58
        if UserDefaults.standard.bool(forKey: CAppConstants.Keys.needsShowTranscribeOrTranslateViewController) {
            UserDefaults.standard.setValue(false, forKey: CAppConstants.Keys.needsShowTranscribeOrTranslateViewController)
            CTranscribServicesAp.shared.requestRecognitionPermission { isAllowed in
                if isAllowed {
                    AppsNavManager.shared.tabBarViewController?.selectTab(with: 1)
                    if let currentSelectedVC = AppsNavManager.shared.tabBarViewController?.currentSelectedNavigationController() {
                        if currentSelectedVC.isKind(of: WSpeechApViewController.self) {
                            let selectedVC = currentSelectedVC as? WSpeechApViewController
                            let openType = UserDefaults.standard.integer(forKey: CAppConstants.Keys.showOpenScreenTypeViewController)
                            selectedVC?.openViewController(with: OpenScreenType(rawValue: openType) ?? .transcribe)
                        }
                    }
                }
            }
        }
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
    func requestIDFA(completion: QAsaServiceApCompletion?) {
        asaServiceAp.requestIDFA(completion: completion)
    }
    
    func remoteConfigValueFor(_ key: String) -> RemoteConfigValue {
        return firebaseServices.remoteConfig.configValue(forKey: key)
    }
    
    func initializeAdjustSDK() {
#if DEBUG
        let environment = ADJEnvironmentSandbox
        let adjustConfig = ADJConfig(
            appToken: CAppConstants.General.adjustApiToken,
            environment: environment)
        adjustConfig?.logLevel = ADJLogLevel.verbose
        adjustConfig?.enableCostDataInAttribution()
        adjustConfig?.delegate = self
#else
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(
            appToken: CAppConstants.General.adjustApiToken,
            environment: environment)
        adjustConfig?.logLevel = ADJLogLevel.suppress
        adjustConfig?.enableCostDataInAttribution()
        adjustConfig?.delegate = self
#endif
        
        Adjust.initSdk(adjustConfig)
    }
}

// MARK: - AdjustDelegate
extension KAppConfigServic: AdjustDelegate {
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        Task {
            if let data = attribution?.dictionary() {
                let adid: String? = await Adjust.adid()
                Apphud.setAttribution(data: nil, from: .adjust, identifer:adid) { (result) in }
            }
        }
    }
    
    func adjustSessionTrackingSucceeded(_ sessionSuccessResponseData: ADJSessionSuccess?) {
        Task {
            if let data = await Adjust.attribution()?.dictionary() {
                let adid: String? = await Adjust.adid()
                Apphud.setAttribution(data: nil, from: .adjust, identifer:adid) { (result) in }
            }
        }
    }
}
