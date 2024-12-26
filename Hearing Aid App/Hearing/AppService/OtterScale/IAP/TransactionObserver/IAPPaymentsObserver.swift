//
//  IAPPaymentsObserver.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 18.01.2022.
//

import StoreKit

protocol IAPPaymentsObserverProtocol {
    init(transactionObserver: IAPTransactionObserverProtocol)
    
    func observe()
}

final class IAPPaymentsObserver: IAPPaymentsObserverProtocol {
    private let transactionObserver: IAPTransactionObserverProtocol
    
    init(transactionObserver: IAPTransactionObserverProtocol) {
        self.transactionObserver = transactionObserver
    }
    
    convenience init(iapManager: IAPManagerProtocol) {
        let delegate = IAPTransactionHandler(iapManager: iapManager)
        let observer = IAPTransactionObserver(delegate: delegate)
        
        self.init(transactionObserver: observer)
    }
}

// MARK: Internal
extension IAPPaymentsObserver {
    func observe() {
        SKPaymentQueue.default().add(transactionObserver)
    }
}
