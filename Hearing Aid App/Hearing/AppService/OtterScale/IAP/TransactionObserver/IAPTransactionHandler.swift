//
//  IAPTransactionHandler.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 18.01.2022.
//

protocol IAPTransactionHandlerProtocol: IAPTransactionDelegate {
    init(iapManager: IAPManagerProtocol,
         productsRequest: IAPProductsRequestProtocol)
}

final class IAPTransactionHandler: IAPTransactionHandlerProtocol {
    private let iapManager: IAPManagerProtocol
    private let productsRequest: IAPProductsRequestProtocol
    
    init(iapManager: IAPManagerProtocol,
         productsRequest: IAPProductsRequestProtocol = IAPProductsRequest()) {
        self.iapManager = iapManager
        self.productsRequest = productsRequest
    }
}

// MARK: IAPTransactionDelegate
extension IAPTransactionHandler {
    func retrieved(transactions: [IAPPaymentTransaction]) {
        let ids = transactions.map { $0.original.payment.productIdentifier }
        
        let validate: ([IAPPrice]) -> Void = { [weak self] prices in
            guard let self = self else {
                return
            }
            
            self.iapManager.validateAppStoreReceipt(prices: prices, completion: nil)
        }
        
        retrievePrices(ids: ids, completion: validate)
    }
}

// MARK: Private
private extension IAPTransactionHandler {
    func retrievePrices(ids: [String], completion: @escaping ([IAPPrice]) -> Void) {
        iapManager.retrieveProducts(ids: ids, request: productsRequest) { products in
            let prices = products.map { product -> IAPPrice in
                let original = product.original
                
                let id = original.productIdentifier
                let price = original.price.doubleValue
                let currency = original.priceLocale.currencyCode ?? ""
                
                return IAPPrice(productID: id,
                                price: price,
                                currency: currency)
            }
            
            completion(prices)
        }
    }
}
