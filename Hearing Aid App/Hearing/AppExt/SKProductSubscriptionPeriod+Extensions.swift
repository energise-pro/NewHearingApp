import StoreKit

extension SKProductSubscriptionPeriod {

    // MARK: - Internal methods
    func localizedPeriod() -> String? {
        return format(unit: calendarUnit, numberOfUnits: numberOfUnits)
    }
    
    // MARK: - Private properties
    private var calendarUnit: NSCalendar.Unit {
        switch self.unit {
        case .day:
            return .day
        case .month:
            return .month
        case .week:
            return .weekOfMonth
        case .year:
            return .year
        @unknown default:
            debugPrint("Unknown period unit")
        }
        return .day
    }
    
    private var componentFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }
    
    // MARK: - Private methods
    private func format(unit: NSCalendar.Unit, numberOfUnits: Int) -> String? {
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        componentFormatter.allowedUnits = [unit]
        switch unit {
        case .day:
            if numberOfUnits == 7 {
                return "Weekly".localized()
            } else {
                dateComponents.setValue(numberOfUnits, for: .day)
                return componentFormatter.string(from: dateComponents)
            }
        case .weekOfMonth:
            let days = numberOfUnits * 7
            dateComponents.setValue(days, for: .day)
            return componentFormatter.string(from: dateComponents)
        case .month:
            return "Monthly".localized()
        case .year:
            return "Yearly".localized()
        default:
            return nil
        }
    }
}
