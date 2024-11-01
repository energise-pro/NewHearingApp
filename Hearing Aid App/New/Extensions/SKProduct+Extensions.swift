import StoreKit
import ApphudSDK

public enum TrialPeriodState {
    case trial
    case regular
    case unspecified
}

extension SKProductDiscount {
    
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

// MARK: - SKProduct
public extension SKProduct {
    
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
    
    var decimalPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
    
    @available(iOS 11.2, tvOS 11.2, *)
    var trialState: TrialPeriodState {
        if let _ = introductoryPrice?.subscriptionPeriod {
            return .trial
        } else {
            return .regular
        }
    }
    
    @available(iOS 11.2, tvOS 11.2, *)
    var expirationDate: Date? {
        var dateComponents = DateComponents()
        switch self.subscriptionPeriod?.unit {
            case .day:
                dateComponents.day = subscriptionPeriod?.numberOfUnits ?? 0
            case .week:
                dateComponents.weekOfMonth = subscriptionPeriod?.numberOfUnits ?? 0
            case .month:
                dateComponents.month = subscriptionPeriod?.numberOfUnits ?? 0
            case .year:
                dateComponents.year = subscriptionPeriod?.numberOfUnits ?? 0
            default: break
        }
        let currentCalendar = Calendar.current
        return currentCalendar.date(byAdding: dateComponents, to: Date())
    }
    
    func regularPrice(for price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: NSNumber(value: price)) ?? ""
    }
    
    func duration(for state: TrialPeriodState) -> String {
        var numberOfUnits: Int?
        var unit: SKProduct.PeriodUnit?
        switch state {
        case .trial:
            numberOfUnits = introductoryPrice?.subscriptionPeriod.numberOfUnits ?? subscriptionPeriod?.numberOfUnits
            unit = introductoryPrice?.subscriptionPeriod.unit ?? subscriptionPeriod?.unit
        default:
            numberOfUnits = subscriptionPeriod?.numberOfUnits
            unit = subscriptionPeriod?.unit
        }
        
        guard var numberOfUnits = numberOfUnits else {
            return ""
        }
        
        var period: String
        switch unit {
            case .day:
                period = numberOfUnits > 1 ? "days".localized() : "day".localized()
                if numberOfUnits == 7 {
                    numberOfUnits = 1
                    period = "week".localized()
                }
            case .week: period = numberOfUnits > 1 ? "weeks".localized() : "week".localized()
            case .month: period = numberOfUnits > 1 ? "months".localized() : "month".localized()
            case .year: period = numberOfUnits > 1 ? "years".localized() : "year".localized()
            default: period = ""
        }
        
        return "\(numberOfUnits) \(period)"
    }
}

extension ApphudPurchaseResult {
    var success: Bool {
        subscription?.isActive() ?? false ||
            nonRenewingPurchase?.isActive() ?? false ||
            (Apphud.isSandbox() && transaction?.transactionState == .purchased)
    }
}
