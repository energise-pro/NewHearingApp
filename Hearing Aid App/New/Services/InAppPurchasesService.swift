import Foundation
import ApphudSDK
import StoreKit
//import iAd

typealias ShopItem = ApphudProduct
typealias SubscriptionPeriod = SKProductSubscriptionPeriod
typealias PurchasesServiceProductCompletion = ([ShopItem]?) -> ()
typealias PurchasesServiceSuccessCompletion = (Bool) -> ()

final class InAppPurchasesService: NSObject, IServiceProtocol {
    
    enum GroupType: String {
        /// These keys can be changed ONLY if you change the group names in https://app.apphud.com
        case subscriptions = "Premium"
        case offer = "Offer"
    }
    
    // MARK: - Internal Properties
    static let TAG = "InAppPurchasesService"
    static let shared: InAppPurchasesService = InAppPurchasesService()
    
    static let didUpdatePurchases = Notification.Name("InAppPurchaseService.didUpdatePurchases")
    
    var isPremium: Bool {
        let subscriptions = Apphud.subscriptions() ?? []
        let purchases = Apphud.nonRenewingPurchases() ?? []
        //return subscriptions.contains { $0.isActive() == true } || purchases.contains { $0.productId == Constants.Keys.lifetimePurchase }
        return true
    }
    
    var wasUsedTrial: Bool {
        get {
            return Bool(KeychainService.stringForKey(keyName: Constants.Keys.wasUsedTrial) ?? "") ?? false
        }
        set {
            KeychainService.setString(value: newValue.toString() ?? "", forKey: Constants.Keys.wasUsedTrial)
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
    
    // MARK: - IServiceProtocol
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
        Logger.log(tag: InAppPurchasesService.TAG, message: "Try to restore purchases")
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
            Logger.log(tag: InAppPurchasesService.TAG, message: "\(isSuccess ? "Successfully" : "Unsuccessfully") restored purchases")
            completion?(isSuccess)
        }
    }
    
    func purchase(_ product: ShopItem, from groupType: GroupType, with completion: PurchasesServiceSuccessCompletion?) {
        Logger.log(tag: InAppPurchasesService.TAG, message: "Try to purchase product with identifier - \(product.productId)")
        Apphud.purchase(product) { [weak self] result in
            if result.subscription?.status == .trial || result.subscription?.status == .intro {
                AppConfiguration.shared.analytics.trackTrial(amount: product.skProduct?.price.doubleValue ?? .zero, currency: product.skProduct?.priceLocale.currencyCode ?? "")
                self?.wasUsedTrial = true
            }
            let isSuccess: Bool = result.error == nil
            isSuccess ? self?.apphudSubscriptionsUpdated([]) : Void()
            Logger.log(tag: InAppPurchasesService.TAG, message: "\(isSuccess ? "Successfully" : "Unsuccessfully") purchased product with identifier - \(product.productId)")
            completion?(isSuccess)
        }
    }
    
    func presentRedeemScreen() {
        Apphud.presentOfferCodeRedemptionSheet()
    }
}

// MARK: - SKPaymentTransactionObserver
extension InAppPurchasesService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) { }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        AppConfiguration.shared.analytics.track(AnalyticsAction.v2AppStore, with: [AnalyticsAction.open.rawValue: "paywall"])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NavigationManager.shared.presentPaywallViewController(with: .openFromAppStore)
        }
        return false
    }
}

// MARK: - ApphudDelegate
extension InAppPurchasesService: ApphudDelegate {
    
    func apphudNonRenewingPurchasesUpdated(_ purchases: [ApphudNonRenewingPurchase]) {
        NotificationCenter.default.post(name: InAppPurchasesService.didUpdatePurchases, object: nil, userInfo: nil)
    }
    
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        NotificationCenter.default.post(name: InAppPurchasesService.didUpdatePurchases, object: nil, userInfo: nil)
    }
    
    func apphudDidChangeUserID(_ userID: String) {
        NotificationCenter.default.post(name: InAppPurchasesService.didUpdatePurchases, object: nil, userInfo: nil)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension InAppPurchasesService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Apphud.handlePushNotification(apsInfo: response.notification.request.content.userInfo)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Apphud.handlePushNotification(apsInfo: notification.request.content.userInfo)
        completionHandler([])
    }
}
