//
//  AppStoreValidateResult.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 15.01.2022.
//

public struct AppStoreValidateResult {
    public let userId: Int?
    public let internalUserID: String?
    public let externalUserID: String?
    public let paymentData: PaymentData
    public let usedProducts: UsedProducts
    public let userSince: String?
    public let accessValidTill: String?
}
