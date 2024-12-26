//
//  InAppPurchase.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 01.02.2022.
//

import Foundation

struct InAppPurchase: Equatable {
    let quantity: Int
    let productId: String
    let transactionId: String
    let originalTransactionId: String
    let productType: InAppPurchaseProductType?
    let purchaseDate: Date
    let originalPurchaseDate: Date
    let expiresDate: Date?
    let cancellationDate: Date?
    let isInTrialPeriod: Bool?
    let webOrderLineItemId: Int64
    let promotionalOfferIdentifier: String?
}

enum InAppPurchaseProductType: Int {
    case unknown = -1,
         nonConsumable,
         consumable,
         nonRenewingSubscription,
         autoRenewableSubscription
}
