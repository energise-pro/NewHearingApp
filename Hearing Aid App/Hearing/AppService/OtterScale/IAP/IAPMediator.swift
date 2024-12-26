//
//  IAPMediator.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 19.01.2022.
//

protocol IAPMediatorProtocol {
    func notifyAbout(result: AppStoreValidateResult?)
    func add(delegate: OtterScaleReceiptValidationDelegate)
    func remove(delegate: OtterScaleReceiptValidationDelegate)
}

final class IAPMediator: IAPMediatorProtocol {
    static let shared = IAPMediator()
    
    private var delegates = [Weak<OtterScaleReceiptValidationDelegate>]()
    
    private init() {}
    
    func notifyAbout(result: AppStoreValidateResult?) {
        delegates.forEach { $0.weak?.otterScaleDidValidatedReceipt(with: result) }
    }
    
    func add(delegate: OtterScaleReceiptValidationDelegate) {
        let weakly = delegate as AnyObject
        delegates.append(Weak<OtterScaleReceiptValidationDelegate>(weakly))
        delegates = delegates.filter { $0.weak != nil }
    }
    
    func remove(delegate: OtterScaleReceiptValidationDelegate) {
        if let index = delegates.firstIndex(where: { $0.weak === delegate }) {
            delegates.remove(at: index)
        }
    }
}
