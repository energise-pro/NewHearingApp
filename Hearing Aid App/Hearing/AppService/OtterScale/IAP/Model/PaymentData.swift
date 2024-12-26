//
//  PaymentData.swift
//  OtterScaleiOS
//
//  Created by Created by Jennifer Taylor on 14.01.2022.
//

public struct PaymentData: Codable {
    public let subscriptions: SubscriptionsPaymentData
    public let nonConsumables: NonConsumablesPaymentData
}

public struct SubscriptionsPaymentData: Codable {
    public let appleAppStore: [SubscriptionPaymentProduct]
    public let googlePlay: [SubscriptionPaymentProduct]
    public let stripe: [SubscriptionPaymentProduct]
    public let paypal: [SubscriptionPaymentProduct]
}

public struct SubscriptionPaymentProduct: Codable {
    public enum Status: String, Codable {
        case refund, trial, paid
    }
    
    public let productID: String
    public let valid: Bool
    public let expiration: String
    public let status: Status
    public let renewing: Bool
}

public struct NonConsumablesPaymentData: Codable {
    public let appleAppStore: [NonConsumablePaymentProduct]
    public let googlePlay: [NonConsumablePaymentProduct]
    public let stripe: [NonConsumablePaymentProduct]
    public let paypal: [NonConsumablePaymentProduct]
}

public struct NonConsumablePaymentProduct: Codable {
    public let productID: String
    public let valid: Bool
}
