//
//  PurchasesService.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import ApphudSDK
import StoreKit
import AppTrackingTransparency
import AdSupport

// MARK: - Typealiases
typealias Product = ApphudProduct
typealias SubscriptionPeriod = SKProductSubscriptionPeriod
typealias PurchaseSuccessCompletion = (Bool) -> Void

final class PurchasesService: NSObject {
    
    // MARK: - Helper Types
    enum ProductGroup: String {
        case premium = "Premium"
    }
    
    enum ProductID: String {
        case monthlySubscription = "com.hearingAidTest.monthly"
        case monthlySubscriptionTrial = "com.hearingAidTest.monthly.withTrial"
        case annualSubscription = "com.hearingAidTest.annual"
        case annualSubscriptionTrial = "com.hearingAidTest.annual.withTrial"
    }
    
    // MARK: - Static Properties
    static let didUpdatePurchases = Notification.Name("didUpdatePurchases")
    static let alertTitle = "Purchases Service".localized
    static let userId = Apphud.userID()
    
    // MARK: - Public Properties
    @UserDefault("wasUsedTrialPeriod")
    var wasUsedTrialPeriod = false
    
    @UserDefault("monthlySubscriptionPrice")
    private(set) var monthlySubscriptionPrice = "$99.99"
    
    var hasPremium: Bool {
        let subscriptions = Apphud.subscriptions() ?? []
        return subscriptions.contains { $0.isActive() }
    }
    
    var annualSubsciptionProfit: String? {
        guard let skProduct = products?.first(where: { $0.skProduct?.subscriptionPeriod?.unit == .year })?.skProduct else { return nil }
        let profit = skProduct.price.doubleValue / 30
        return SKProduct.getLocalizedPrice(for: skProduct.priceLocale, price: profit)
    }
    
    // MARK: - Private Properties
    private let apiKey: String
    private let logService: LogService
    private var numberOfAttepts = 0
    private var products: [Product]?
    private var timers = [Timer]()
    
    // MARK: - Object Lifecycle
    override init() {
        fatalError("You should use another init method")
    }
    
    init(apiKey: String, logService: LogService) {
        self.apiKey = apiKey
        self.logService = logService
    }
    
    deinit {
        invalidateTimers()
    }
    
    // MARK: - Public Method
    func start() {
        Apphud.start(apiKey: apiKey)
        Apphud.setDelegate(self)
        SKPaymentQueue.default().add(self)
        UNUserNotificationCenter.current().delegate = self
    }
    
    func fetchProducts(from group: ProductGroup, completion: (([Product]?) -> Void)? = nil) {
        let operation = "Fetch products from group: \(group.rawValue)"
        printDetails(operation: operation)
        let permissionGroup = Apphud.permissionGroups.first(where: { $0.name == group.rawValue })
        
        func returnProducts() {
            products = permissionGroup?.products
            completion?(products)
            printDetails(operation: operation, isSuccess: products != nil, products: products)
        }
        
        guard Apphud.permissionGroups.isEmpty || permissionGroup?.products.contains(where: { $0.skProduct == nil }) == true else {
            returnProducts()
            return
        }
        
        Apphud.paywallsDidLoadCallback { [weak self] _ in
            guard let self = self else { return }
            guard Apphud.permissionGroups.isEmpty || self.products?.contains(where: { $0.skProduct == nil }) == true else {
                returnProducts()
                return
            }
            guard self.numberOfAttepts < 4 else { self.invalidateTimers(); return }
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                self.numberOfAttepts += 1
                self.fetchProducts(from: group, completion: completion)
            }
            self.timers.append(timer)
        }
    }
    
    func fetchMonthlySubscriptionInfo(from group: ProductGroup, completion: (() -> Void)? = nil) {
        let operation = "Fetching monthly subscription info from group: \(group.rawValue)"
        printDetails(operation: operation)
        fetchProducts(from: group) { [weak self] products in
            guard
                let monthlySubscription = products?.first(where: { $0.productId == ProductID.monthlySubscription.rawValue }),
                let localizedPrice = monthlySubscription.skProduct?.localizedPrice
            else {
                self?.printDetails(operation: operation, isSuccess: false)
                completion?()
                return
            }
            self?.printDetails(operation: operation, isSuccess: true, products: [monthlySubscription])
            self?.monthlySubscriptionPrice = localizedPrice
            completion?()
        }
    }
    
    func restorePurchases(completion: ((Bool) -> Void)? = nil) {
        let operation = "Restoring purchases"
        printDetails(operation: operation)
        Apphud.restorePurchases { [weak self] subscriptions, purchases, error in
            let isSuccess = error == nil && (subscriptions?.contains(where: { $0.isActive() }) == true || purchases?.contains(where: { $0.isActive() }) == true)
            self?.printDetails(operation: operation, isSuccess: isSuccess)
            guard isSuccess else {
                completion?(false)
                return
            }
            if let subscriptions = subscriptions {
                self?.apphudSubscriptionsUpdated(subscriptions)
            } else if let purchases = purchases {
                self?.apphudNonRenewingPurchasesUpdated(purchases)
            }
            completion?(isSuccess)
        }
    }
    
    func purchase(product: Product, from group: ProductGroup, completion: ((Bool) -> Void)? = nil) {
        let operation = "Product purchase with productId: \(product.productId)"
        printDetails(operation: operation)
        Apphud.purchase(product) { [weak self] result in
            if result.subscription?.status == .trial || result.subscription?.status == .intro {
                self?.wasUsedTrialPeriod = true
            }
            let isSuccess = result.error == nil
            if isSuccess {
                self?.apphudSubscriptionsUpdated([])
                self?.printDetails(operation: operation, isSuccess: isSuccess)
            }
            completion?(isSuccess)
        }
    }
    
    func requestTrackingTransparencyAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            let operation = "Requesting Tracking Transparency Authorization"
            self?.printDetails(operation: operation, isSuccess: status == .authorized)
        }
    }
    
    // MARK: - Private Methods
    private func invalidateTimers() {
        timers.forEach { $0.invalidate() }
        timers = []
    }
    
    private func printDetails(operation: String, isSuccess: Bool? = nil, products: [Product]? = nil) {
        var details = "| \(operation) |"
        if let isSuccess = isSuccess {
            let statusDetails = " \(isSuccess ? "✅" : "❌") Status: \(isSuccess ? "Successfully" : "Unsuccessfully") |"
            details += statusDetails
        }
        if let products = products {
            let fetchedProducts = products.map { "Name: \($0.name ?? "(no name)"), ID: \($0.productId), Price: \($0.skProduct?.localizedPrice ?? "nil")" }
            details += "\n" + fetchedProducts.joined(separator: "\n")
        }
        let line = String(repeating: "-", count: details.count)
        print("\n\(line)")
        logService.write(.💰, details)
        print(line)
    }
}

// MARK: - ApphudDelegate
extension PurchasesService: ApphudDelegate {
    
    func apphudNonRenewingPurchasesUpdated(_ purchases: [ApphudNonRenewingPurchase]) {
        NotificationCenter.default.post(name: PurchasesService.didUpdatePurchases, object: nil)
    }
    
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        NotificationCenter.default.post(name: PurchasesService.didUpdatePurchases, object: nil)
    }
    
    func apphudDidChangeUserID(_ userID: String) {
        NotificationCenter.default.post(name: PurchasesService.didUpdatePurchases, object: nil)
    }
}

// MARK: - SKPaymentTransactionObserver
extension PurchasesService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) { }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        // TODO: - Show the paywall screen
        return false
    }
    
}

// MARK: - UNUserNotificationCenterDelegate
extension PurchasesService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Apphud.handlePushNotification(apsInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Apphud.handlePushNotification(apsInfo: notification.request.content.userInfo)
        completionHandler([])
    }
}
