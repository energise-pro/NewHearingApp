//
//  OtterScaleReceiptValidationDelegate.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 19.01.2022.
//

public protocol OtterScaleReceiptValidationDelegate: AnyObject {
    func otterScaleDidValidatedReceipt(with result: AppStoreValidateResult?)
}
