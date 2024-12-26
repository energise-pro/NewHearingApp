//
//  IAPValidateAppStoreReceipt.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 15.01.2022.
//

protocol IAPValidateAppStoreReceiptProtocol {
    func validate(appStoreReceipt: String,
                  prices: [IAPPrice],
                  completion: ((AppStoreValidateResult?) -> Void)?)
}

final class IAPValidateAppStoreReceipt: IAPValidateAppStoreReceiptProtocol {
    deinit {
        operation = nil
    }
    
    private var operation: APIOperation?
    private lazy var operationWrapper = APIOperationWrapper()
    
    private let storage: StorageProtocol
    private let requestDispatcher: RequestDispatcherProtocol
    private let apiEnvironment: APIEnvironmentProtocol
    private let mapper: ValidateAppStoreReceiptResponseProtocol
    private let appStoreReceiptSource: AppStoreReceiptSourceProtocol
    private let paymentDataBuilder: PaymentDataBuilderProtocol
    
    init(storage: StorageProtocol,
         requestDispatcher: RequestDispatcherProtocol,
         apiEnvironment: APIEnvironmentProtocol,
         mapper: ValidateAppStoreReceiptResponseProtocol = ValidateAppStoreReceiptResponse(),
         appStoreReceiptSource: AppStoreReceiptSourceProtocol = AppStoreReceiptSource(),
         paymentDataBuilder: PaymentDataBuilderProtocol = PaymentDataBuilder()) {
        self.storage = storage
        self.requestDispatcher = requestDispatcher
        self.apiEnvironment = apiEnvironment
        self.mapper = mapper
        self.appStoreReceiptSource = appStoreReceiptSource
        self.paymentDataBuilder = paymentDataBuilder
    }
}

// MARK: Internal
extension IAPValidateAppStoreReceipt {
    func validate(appStoreReceipt: String,
                  prices: [IAPPrice] = [],
                  completion: ((AppStoreValidateResult?) -> Void)?) {
        let request = ValidateAppStoreReceiptRequest(apiKey: apiEnvironment.apiKey,
                                                     anonymousID: storage.anonymousID,
                                                     externalUserID: storage.externalUserID,
                                                     internalUserID: storage.internalUserID,
                                                     appStoreReceipt: appStoreReceipt,
                                                     prices: prices)
        
        operation = APIOperation(endPoint: request)
        
        operationWrapper.execute(operation: operation!, dispatcher: requestDispatcher) { [weak self] result in
            guard let self = self else {
                return
            }
            
            let appStoreValidateResult: AppStoreValidateResult?
            
            if
                let response = result,
                let mapperResult = self.mapper.map(response: response) {
                if self.hasActiveSubscriptions(paymentData: mapperResult.paymentData) {
                    appStoreValidateResult = mapperResult
                } else {
                    if let local = self.tryLocalParseReceipt() {
                        if self.hasActiveSubscriptions(paymentData: local.paymentData) {
                            appStoreValidateResult = local
                        } else {
                            appStoreValidateResult = mapperResult
                        }
                    } else {
                        appStoreValidateResult = mapperResult
                    }
                }
            } else {
                appStoreValidateResult = self.tryLocalParseReceipt()
            }

            completion?(appStoreValidateResult)
            
            self.operation = nil
        }
    }
}

// MARK: Private
private extension IAPValidateAppStoreReceipt {
    func tryLocalParseReceipt() -> AppStoreValidateResult? {
        guard let receipt = appStoreReceiptSource.appStoreReceipt(parser: AppStoreReceiptParser()) else {
            return nil
        }
        
        let paymentData = paymentDataBuilder.build(purchases: receipt.inAppPurchases)
        
        let result = merge(paymentData: paymentData,
                           cached: storage.paymentData,
                           userId: storage.userId,
                           internalUserID: storage.internalUserID,
                           externalUserID: storage.externalUserID,
                           usedProducts: storage.usedProducts ?? UsedProducts(appleAppStore: [],
                                                                              googlePlay: [],
                                                                              stripe: []),
                           userSince: storage.userSince,
                           accessValidTill: storage.accessValidTill)
        
        return result
    }
    
    func merge(paymentData: PaymentData,
               cached: PaymentData?,
               userId: Int?,
               internalUserID: String?,
               externalUserID: String?,
               usedProducts: UsedProducts,
               userSince: String?,
               accessValidTill: String?) -> AppStoreValidateResult {
        let subscriptions = SubscriptionsPaymentData(appleAppStore: paymentData.subscriptions.appleAppStore,
                                                     googlePlay: cached?.subscriptions.googlePlay ?? [],
                                                     stripe: cached?.subscriptions.stripe ?? [],
                                                     paypal: cached?.subscriptions.paypal ?? [])
        let nonConsumables = NonConsumablesPaymentData(appleAppStore: paymentData.nonConsumables.appleAppStore,
                                                       googlePlay: cached?.nonConsumables.googlePlay ?? [],
                                                       stripe: cached?.nonConsumables.googlePlay ?? [],
                                                       paypal: cached?.nonConsumables.paypal ?? [])
        
        let data = PaymentData(subscriptions: subscriptions,
                               nonConsumables: nonConsumables)
        
        return AppStoreValidateResult(userId: userId,
                                      internalUserID: internalUserID,
                                      externalUserID: externalUserID,
                                      paymentData: data,
                                      usedProducts: usedProducts,
                                      userSince: userSince,
                                      accessValidTill: accessValidTill)
    }
    
    func hasActiveSubscriptions(paymentData: PaymentData) -> Bool {
        let subscriptions = paymentData.subscriptions.appleAppStore
            + paymentData.subscriptions.googlePlay
            + paymentData.subscriptions.stripe
            + paymentData.subscriptions.paypal
        let nonConsumables = paymentData.nonConsumables.appleAppStore
            + paymentData.nonConsumables.googlePlay
            + paymentData.nonConsumables.stripe
            + paymentData.nonConsumables.paypal

        let hasValidSubscription = subscriptions.contains(where: { $0.valid })
        let hasValidNonConsumable = nonConsumables.contains(where: { $0.valid })

        return hasValidSubscription || hasValidNonConsumable
    }
}
