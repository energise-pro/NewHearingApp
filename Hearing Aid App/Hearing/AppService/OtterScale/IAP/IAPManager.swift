//
//  IAPManager.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 14.01.2022.
//

import StoreKit

protocol IAPManagerProtocol {
    func fetchAppStoreReceipt(completion: @escaping (String?) -> Void)
    func validateAppStoreReceipt(prices: [IAPPrice],
                                 completion: ((AppStoreValidateResult?) -> Void)?)
    func obtainAppStoreValidateResult(mapper: ValidateAppStoreReceiptResponseProtocol,
                                      completion: ((AppStoreValidateResult?) -> Void)?)
    func retrieveProducts(ids: [String],
                          request: IAPProductsRequestProtocol,
                          completion: @escaping ([IAPProduct]) -> Void)
}

final class IAPManager: IAPManagerProtocol {
    private let apiEnvironment: APIEnvironmentProtocol
    private var storage: StorageProtocol
    private let appStoreReceiptFetcher: AppStoreReceiptFetcherProtocol
    private let appStoreReceiptValidator: IAPValidateAppStoreReceiptProtocol
    private let requestDispatcher: RequestDispatcherProtocol
    private let mediator: IAPMediatorProtocol
    
    private lazy var operations = [String: APIOperationProtocol]()
    private lazy var operationWrapper = APIOperationWrapper()
    
    init(apiEnvironment: APIEnvironmentProtocol,
         storage: StorageProtocol,
         appStoreReceiptFetcher: AppStoreReceiptFetcherProtocol,
         appStoreReceiptValidator: IAPValidateAppStoreReceiptProtocol,
         requestDispatcher: RequestDispatcherProtocol,
         mediator: IAPMediatorProtocol) {
        self.apiEnvironment = apiEnvironment
        self.storage = storage
        self.appStoreReceiptFetcher = appStoreReceiptFetcher
        self.appStoreReceiptValidator = appStoreReceiptValidator
        self.requestDispatcher = requestDispatcher
        self.mediator = mediator
    }
    
    convenience init(apiEnvironment: APIEnvironmentProtocol,
                     storage: StorageProtocol,
                     mediator: IAPMediatorProtocol) {
        let requestDispatcher = RequestDispatcher(environment: apiEnvironment,
                                                  networkSession: NetworkSession())
        
        let appStoreReceiptValidator = IAPValidateAppStoreReceipt(storage: storage,
                                                                  requestDispatcher: requestDispatcher,
                                                                  apiEnvironment: apiEnvironment)
        
        self.init(apiEnvironment: apiEnvironment,
                  storage: storage,
                  appStoreReceiptFetcher: AppStoreReceiptFetcher(),
                  appStoreReceiptValidator: appStoreReceiptValidator,
                  requestDispatcher: requestDispatcher,
                  mediator: mediator)
    }
}

// MARK: Internal
extension IAPManager {
    func fetchAppStoreReceipt(completion: @escaping (String?) -> Void) {
        appStoreReceiptFetcher.fetch(completion: completion)
    }
    
    func validateAppStoreReceipt(prices: [IAPPrice] = [],
                                 completion: ((AppStoreValidateResult?) -> Void)? = nil) {
        let validatorCompletion: ((AppStoreValidateResult?) -> Void) = { [weak self] result in
            guard let self = self else {
                return
            }
            
            if let result = result {
                self.storage.userId = result.userId
                self.storage.internalUserID = result.internalUserID
                self.storage.externalUserID = result.externalUserID
                self.storage.paymentData = result.paymentData
                self.storage.usedProducts = result.usedProducts
                self.storage.userSince = result.userSince
                self.storage.accessValidTill = result.accessValidTill
            }
            
            self.mediator.notifyAbout(result: result)
            
            completion?(result)
        }
        
        fetchAppStoreReceipt { [weak self] appStoreReceipt in
            guard let self = self, let appStoreReceipt = appStoreReceipt else {
                validatorCompletion(nil)
                return
            }
            
            self.appStoreReceiptValidator.validate(appStoreReceipt: appStoreReceipt,
                                                   prices: prices,
                                                   completion: validatorCompletion)
        }
    }
    
    func obtainAppStoreValidateResult(mapper: ValidateAppStoreReceiptResponseProtocol = ValidateAppStoreReceiptResponse(),
                                      completion: ((AppStoreValidateResult?) -> Void)? = nil) {
        let request = ObtainAppStoreValidateResultRequest(apiKey: apiEnvironment.apiKey,
                                                          externalUserID: storage.externalUserID,
                                                          internalUserID: storage.internalUserID)
        let operation = APIOperation(endPoint: request)
        
        let key = "obtain_app_store_validation_result_request"
        
        operations[key] = operation
        
        operationWrapper.execute(operation: operation, dispatcher: requestDispatcher) { [weak self] response in
            guard let self = self else {
                return
            }
            
            if let response = response, let result = mapper.map(response: response) {
                self.storage.userId = result.userId
                self.storage.internalUserID = result.internalUserID
                self.storage.externalUserID = result.externalUserID
                self.storage.paymentData = result.paymentData
                self.storage.usedProducts = result.usedProducts
                self.storage.userSince = result.userSince
                self.storage.accessValidTill = result.accessValidTill
                
                completion?(result)
            } else {
                completion?(nil)
            }
            
            self.operations.removeValue(forKey: key)
        }
    }
    
    func retrieveProducts(ids: [String],
                          request: IAPProductsRequestProtocol,
                          completion: @escaping ([IAPProduct]) -> Void) {
        request.retrieve(ids: ids, completion: completion)
    }
}
