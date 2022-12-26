//
//  SKProduct+Ext.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 16.12.2022.
//

import StoreKit

extension SKProduct {
    
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var localizedPrice: String? {
        SKProduct.formatter.locale = priceLocale
        return SKProduct.formatter.string(from: price)
    }
    
    static func getLocalizedPrice(for locale: Locale, price: Double) -> String? {
        SKProduct.formatter.locale = locale
        return SKProduct.formatter.string(from: price as NSNumber)
    }
}
