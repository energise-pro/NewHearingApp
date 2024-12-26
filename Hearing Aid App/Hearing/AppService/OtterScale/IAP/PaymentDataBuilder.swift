//
//  PaymentDataBuilder.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 01.02.2022.
//

import Foundation

protocol PaymentDataBuilderProtocol {
    func build(purchases: [InAppPurchase]) -> PaymentData
}

final class PaymentDataBuilder: PaymentDataBuilderProtocol {
    func build(purchases: [InAppPurchase]) -> PaymentData {
        let (subscriptions, nonConsumables) = divide(purchases: purchases)
        
        let subscriptionsProducts = subscriptions.compactMap { buildSubscription(from: $0) }
        let nonConsumablesProducts = nonConsumables.compactMap { buildNonConsumable(from: $0) }
        
        let subscriptionsPaymentData = SubscriptionsPaymentData(appleAppStore: subscriptionsProducts,
                                                                googlePlay: [],
                                                                stripe: [],
                                                                paypal: [])
        let nonConsumablesPaymentData = NonConsumablesPaymentData(appleAppStore: nonConsumablesProducts,
                                                                  googlePlay: [],
                                                                  stripe: [],
                                                                  paypal: [])
        
        return PaymentData(subscriptions: subscriptionsPaymentData,
                           nonConsumables: nonConsumablesPaymentData)
    }
}

// MARK: Private
private extension PaymentDataBuilder {
    func divide(purchases: [InAppPurchase]) -> (subscriptions: [InAppPurchase], nonConsumables: [InAppPurchase]) {
        var subscriptions = [InAppPurchase]()
        var nonConsumables = [InAppPurchase]()
        
        let dict = Dictionary(grouping: purchases, by: { $0.productId })
        
        dict.forEach { (key: String, value: [InAppPurchase]) in
            let latestPurchase = value.max(by: { purchase1, purchase2 -> Bool in
                guard let purchase1Date = purchase1.expiresDate, let purchase2Date = purchase2.expiresDate else {
                    return false
                }
                
                return purchase1Date.compare(purchase2Date) == .orderedAscending
            })
            
            guard let latestPurchase = latestPurchase else {
                return
            }
            
            guard let type = latestPurchase.productType else {
                return
            }
            
            switch type {
            case .autoRenewableSubscription, .nonRenewingSubscription:
                subscriptions.append(latestPurchase)
            case .consumable, .nonConsumable:
                nonConsumables.append(latestPurchase)
            case .unknown:
                return
            }
        }
        
        return (subscriptions: subscriptions, nonConsumables: nonConsumables)
    }
    
    func buildSubscription(from purchase: InAppPurchase) -> SubscriptionPaymentProduct? {
        guard
            let expiresDate = purchase.expiresDate,
            let status = detectStatus(purchase: purchase)
        else {
            return nil
        }
        
        let expiration = ISO8601DateFormatter.default.string(from: expiresDate)
        
        let currentDate = Date()
        let expired = currentDate > expiresDate
        let valid = (status != .refund) && !expired
        
        return SubscriptionPaymentProduct(productID: purchase.productId,
                                          valid: valid,
                                          expiration: expiration,
                                          status: status,
                                          renewing: valid)
    }
    
    func buildNonConsumable(from purchase: InAppPurchase) -> NonConsumablePaymentProduct? {
        guard let status = detectStatus(purchase: purchase) else {
            return nil
        }
        
        let valid = status != .refund
        
        return NonConsumablePaymentProduct(productID: purchase.productId,
                                           valid: valid)
    }
    
    func detectStatus(purchase: InAppPurchase) -> SubscriptionPaymentProduct.Status? {
        guard let type = purchase.productType else {
            return nil
        }
        
        let refund = purchase.cancellationDate != nil
        
        switch type {
        case .autoRenewableSubscription, .nonRenewingSubscription:
            if refund {
                return .refund
            }
            
            let inTrial = purchase.isInTrialPeriod ?? false
            
            return inTrial ? .trial : .paid
        case .nonConsumable, .consumable:
            return refund ? .refund : .paid
        case .unknown:
            return nil
        }
    }
}
