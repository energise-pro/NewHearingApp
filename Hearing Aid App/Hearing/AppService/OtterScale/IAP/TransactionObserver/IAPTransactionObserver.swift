//
//  IAPTransactionObserver.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 18.01.2022.
//

import StoreKit

protocol IAPTransactionDelegate: AnyObject {
    func retrieved(transactions: [IAPPaymentTransaction])
}

protocol IAPTransactionObserverProtocol: SKPaymentTransactionObserver {
    init(delegate: IAPTransactionDelegate)
}

final class IAPTransactionObserver: NSObject, IAPTransactionObserverProtocol {
    private let delegate: IAPTransactionDelegate
    
    init(delegate: IAPTransactionDelegate) {
        self.delegate = delegate
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let filtered = transactions
            .filter { $0.transactionState == .purchased || $0.transactionState == .restored }
            .map { IAPPaymentTransaction(original: $0) }
        
        guard !filtered.isEmpty else {
            return
        }
        
        delegate.retrieved(transactions: filtered)
    }
}
