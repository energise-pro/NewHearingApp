//
//  IAPProductsRequest.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 18.01.2022.
//

import StoreKit

protocol IAPProductsRequestProtocol: SKProductsRequestDelegate {
    func retrieve(ids: [String], completion: @escaping (([IAPProduct]) -> Void))
}

final class IAPProductsRequest: NSObject, IAPProductsRequestProtocol {
    deinit {
        request = nil
        completion = nil
    }
    
    private var request: SKProductsRequest?
    
    private var completion: (([IAPProduct]) -> Void)?
}

// MARK: Internal
extension IAPProductsRequest {
    func retrieve(ids: [String], completion: @escaping (([IAPProduct]) -> Void)) {
        self.completion = completion
        
        let productIdentifiers = Set(ids)
        
        request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request?.delegate = self
        request?.start()
    }
}

// MARK: SKProductsRequestDelegate
extension IAPProductsRequest {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products.map { IAPProduct(original: $0) }
        
        completion?(products)
    }
}
