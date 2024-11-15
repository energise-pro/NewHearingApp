import Foundation
import ApphudSDK
import StoreKit
//import iAd

typealias ShopItem = ApphudProduct
typealias SubscriptionPeriod = SKProductSubscriptionPeriod
typealias PurchasesServiceProductCompletion = ([ShopItem]?) -> ()
typealias PurchasesServiceSuccessCompletion = (Bool) -> ()

final class TInAppService: NSObject, DIServicProtocols {
    
    enum GroupType: String {
        /// These keys can be changed ONLY if you change the group names in https://app.apphud.com
        case subscriptions = "Premium"
        case offer = "Offer"
    }
    
    // MARK: - Internal Properties
    static let TAG = "TInAppService"
    static let shared: TInAppService = TInAppService()
    
    static let didUpdatePurchases = Notification.Name("InAppPurchaseService.didUpdatePurchases")
    
    var isPremium: Bool {
        let subscriptions = Apphud.subscriptions() ?? []
//        let purchases = Apphud.nonRenewingPurchases() ?? []
        return subscriptions.contains { $0.isActive() == true } // || purchases.contains { $0.productId == CAppConstants.Keys.lifetimePurchase }
        //return true
    }
    
    var wasUsedTrial: Bool {
        get {
            return Bool(UKeyServices.stringForKey(keyName: CAppConstants.Keys.wasUsedTrial) ?? "") ?? false
        }
        set {
            UKeyServices.setString(value: newValue.toString() ?? "", forKey: CAppConstants.Keys.wasUsedTrial)
        }
    }
    
    // MARK: - Properties
    private let apiKey: String
    private var numberOfAttepts: Int = 0
    
    // MARK: - Init
    override init() {
        self.apiKey = ""
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - DIServicProtocols
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Apphud.start(apiKey: apiKey)
        Apphud.setDelegate(self)
        
        SKPaymentQueue.default().add(self)
        UNUserNotificationCenter.current().delegate = self
    }
    
    func fetchProducts(with groupType: GroupType, and completion: PurchasesServiceProductCompletion?) {
        func returnSubscriptions() {
            let products = Apphud.permissionGroups.first(where: { $0.name == groupType.rawValue })?.products
            completion?(products)
        }
        
        if !Apphud.permissionGroups.isEmpty, Apphud.permissionGroups.first(where: { $0.name == groupType.rawValue })?.products.contains(where: { $0.skProduct == nil }) == false {
            returnSubscriptions()
        } else {
            Apphud.paywallsDidLoadCallback { [weak self] _ in
                guard let self = self else {
                    return
                }
                guard Apphud.permissionGroups.isEmpty, Apphud.permissionGroups.first(where: { $0.name == groupType.rawValue })?.products.contains(where: { $0.skProduct == nil }) == true else {
                    returnSubscriptions()
                    return
                }
                
                guard self.numberOfAttepts < 4 else { return }
                
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    self.numberOfAttepts += 1
                    self.fetchProducts(with: groupType, and: completion)
                }
            }
        }
    }
    
    func restorePurchases(_ completion: PurchasesServiceSuccessCompletion?) {
        LoggerApp.log(tag: TInAppService.TAG, message: "Try to restore purchases")
        Apphud.restorePurchases { [weak self] (subscriptions, nonRenewingPurchase, error) in
            let isSuccess = error == nil && (subscriptions?.contains { $0.isActive() } == true || nonRenewingPurchase?.contains { $0.isActive() } == true)
            guard isSuccess else {
                completion?(false)
                return
            }
            if let subscriptions = subscriptions {
                self?.apphudSubscriptionsUpdated(subscriptions)
            } else if let nonRenewingPurchase = nonRenewingPurchase {
                self?.apphudNonRenewingPurchasesUpdated(nonRenewingPurchase)
            }
            LoggerApp.log(tag: TInAppService.TAG, message: "\(isSuccess ? "Successfully" : "Unsuccessfully") restored purchases")
            completion?(isSuccess)
        }
    }
    
    func purchase(_ product: ShopItem, from groupType: GroupType, with completion: PurchasesServiceSuccessCompletion?) {
        LoggerApp.log(tag: TInAppService.TAG, message: "Try to purchase product with identifier - \(product.productId)")
        Apphud.purchase(product) { [weak self] result in
            if result.subscription?.status == .trial || result.subscription?.status == .intro {
                KAppConfigServic.shared.analytics.trackTrial(amount: product.skProduct?.price.doubleValue ?? .zero, currency: product.skProduct?.priceLocale.currencyCode ?? "")
                self?.wasUsedTrial = true
            }
            let isSuccess: Bool = result.error == nil
            isSuccess ? self?.apphudSubscriptionsUpdated([]) : Void()
            LoggerApp.log(tag: TInAppService.TAG, message: "\(isSuccess ? "Successfully" : "Unsuccessfully") purchased product with identifier - \(product.productId)")
            completion?(isSuccess)
        }
    }
    
    func presentRedeemScreen() {
        Apphud.presentOfferCodeRedemptionSheet()
    }
}

// MARK: - SKPaymentTransactionObserver
extension TInAppService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) { }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        KAppConfigServic.shared.analytics.track(GAppAnalyticActions.v2AppStore, with: [GAppAnalyticActions.open.rawValue: "paywall"])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AppsNavManager.shared.presentPaywallViewController(with: .openFromAppStore)
        }
        return false
    }
}

// MARK: - ApphudDelegate
extension TInAppService: ApphudDelegate {
    
    func apphudNonRenewingPurchasesUpdated(_ purchases: [ApphudNonRenewingPurchase]) {
        NotificationCenter.default.post(name: TInAppService.didUpdatePurchases, object: nil, userInfo: nil)
    }
    
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        NotificationCenter.default.post(name: TInAppService.didUpdatePurchases, object: nil, userInfo: nil)
    }
    
    func apphudDidChangeUserID(_ userID: String) {
        NotificationCenter.default.post(name: TInAppService.didUpdatePurchases, object: nil, userInfo: nil)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension TInAppService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Apphud.handlePushNotification(apsInfo: response.notification.request.content.userInfo)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Apphud.handlePushNotification(apsInfo: notification.request.content.userInfo)
        completionHandler([])
    }
}
