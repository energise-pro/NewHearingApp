//
//  OtterScaleInteractor.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 16.01.2022.
//

final class OtterScaleInteractor {
    private lazy var storage = Storage()
    private lazy var launches = NumberLaunches()
    
    private var apiEnvironment: APIEnvironmentProtocol!
    
    private lazy var analyticsManager = OtterScaleAnalyticsManager(apiEnvironment: apiEnvironment,
                                                                   storage: storage)
    
    private lazy var iapMediator = IAPMediator.shared
    private lazy var iapManager = IAPManager(apiEnvironment: apiEnvironment,
                                             storage: storage,
                                             mediator: iapMediator)
    private lazy var iapPaymentsObserver = IAPPaymentsObserver(iapManager: iapManager)
    
    private lazy var userManager = UserManager(apiEnvironment: apiEnvironment,
                                               storage: storage)
    private lazy var userUpdater = UserUpdater(manager: userManager,
                                               mediator: iapMediator,
                                               storage: storage)
}

// MARK: Internal
extension OtterScaleInteractor {
    func initialize(host: String, apiKey: String) {
        launches.launch()
        
        apiEnvironment = APIEnvironment(host: host, apiKey: apiKey)
        
        startPaymentsObserve()
        initializeInternalLaunch()
        initializeAuth()
    }
    
    func set(userID: String) {
        userManager.set(userID: userID) { [weak self] success in
            guard let self = self, success else {
                return
            }
            
            self.updatePaymentData()
        }
    }
    
    func set(internalUserID: String) {
        storage.internalUserID = internalUserID
        updatePaymentData(forceValidation: true)
    }
    
    func set(properties: [String: Any]) {
        userManager.set(properties: properties)
    }
    
    func set(pushNotificationsToken: String) {
        storage.pushNotificationsToken = pushNotificationsToken
        userManager.set(properties: [
            "firebase_notification_key": pushNotificationsToken
        ])
    }
    
    func getUserID() -> Int? {
        storage.userId
    }
    
    func getAnonymousID() -> String {
        storage.anonymousID
    }
    
    func getInternalID() -> String {
        storage.internalUserID ?? storage.anonymousID
    }
    
    func getPaymentData() -> PaymentData? {
        storage.paymentData
    }
    
    func getSubscriptions() -> SubscriptionsPaymentData? {
        storage.paymentData?.subscriptions
    }
    
    func getNonConsumables() -> NonConsumablesPaymentData? {
        storage.paymentData?.nonConsumables
    }
    
    func getUsedProducts() -> UsedProducts? {
        storage.usedProducts
    }
    
    func getUserSince() -> String? {
        storage.userSince
    }
    
    func getAccessValidTill() -> String? {
        storage.accessValidTill
    }
    
    func updatePaymentData(forceValidation: Bool = false,
                           completion: ((PaymentData?) -> Void)? = nil) {
        let finish: (AppStoreValidateResult?) -> Void = { result in
            completion?(result?.paymentData)
        }
        
        if forceValidation {
            iapManager.validateAppStoreReceipt(completion: finish)
        } else {
            iapManager.obtainAppStoreValidateResult(completion: finish)
        }
    }
    
    func add(delegate: OtterScaleReceiptValidationDelegate) {
        iapMediator.add(delegate: delegate)
    }
    
    func remove(delegate: OtterScaleReceiptValidationDelegate) {
        iapMediator.remove(delegate: delegate)
    }
}

// MARK: Private
private extension OtterScaleInteractor {
    func initializeInternalLaunch() {
        userUpdater.startTracking()
    }
    
    func startPaymentsObserve() {
        iapPaymentsObserver.observe()
    }
    
    func initializeAuth() {
        guard launches.isFirstLaunch() else {
            iapManager.validateAppStoreReceipt()
            return
        }
        
        analyticsManager.registerInstall { [weak self] in
            self?.analyticsManager.syncADServiceToken()
            self?.iapManager.validateAppStoreReceipt()
        }
    }
}
