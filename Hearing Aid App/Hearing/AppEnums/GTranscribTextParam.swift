import UIKit

enum GTranscribTextParam: String, CaseIterable {
    case FontSize
    case FontWeight
    case TextAlignment
    
    var title: String {
        switch self {
        case .FontSize:
            return "Font size".localized()
        case .FontWeight:
            return "Font weight".localized()
        case .TextAlignment:
            return "Text alignment".localized()
        }
    }
    
    var minValue: Int {
        switch self {
        case .FontSize:
            return 20
        case .FontWeight:
            return 0
        case .TextAlignment:
            return NSTextAlignment.left.rawValue
        }
    }

    var maxValue: Int {
        switch self {
        case .FontSize:
            return iPhone ? 200 : 300
        case .FontWeight:
            return 2
        case .TextAlignment:
            return NSTextAlignment.natural.rawValue
        }
    }

    var defaultValue: Int {
        switch self {
        case .FontSize:
            return 30
        case .FontWeight:
            return 2
        case .TextAlignment:
            return NSTextAlignment.center.rawValue
        }
    }
    
    var uiFontWieght: UIFont.Weight {
        guard self == .FontWeight else {
            return .regular
        }
        switch value {
        case 0:
            return .medium
        case 1:
            return .semibold
        default:
            return .bold
        }
    }
        
    var value: Int {
        return (UserDefaults.standard.value(forKey: self.rawValue) as? Int) ?? defaultValue
    }
    
    func setNew(_ value: Int) {
        UserDefaults.standard.setValue(value, forKey: self.rawValue)
    }
}
