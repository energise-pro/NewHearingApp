import UIKit

let ThemeDidChangeNotificationName = Notification.Name.init("ThemeDidChangeColor")

enum ColorType: Int, CaseIterable {
    case purpule
    case orange
    case red
    case blue
    case green

    var color: UIColor {
        switch self {
        case .purpule:
            return #colorLiteral(red: 0.4862745098, green: 0.2509803922, blue: 0.8, alpha: 1)
        case .orange:
            return #colorLiteral(red: 1, green: 0.5137254902, blue: 0, alpha: 1)
        case .red:
            return #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        case .blue:
            return #colorLiteral(red: 0, green: 0.4731103778, blue: 1, alpha: 1)
        case .green:
            return #colorLiteral(red: 0, green: 0.8917200565, blue: 0, alpha: 1)
        }
    }
    
    var analyticAction: AnalyticsAction {
        switch self {
        case .blue:
            return AnalyticsAction.blue
        case .purpule:
            return AnalyticsAction.violet
        case .orange:
            return AnalyticsAction.orange
        case .red:
            return AnalyticsAction.red
        case .green:
            return AnalyticsAction.green
        }
    }
}

final class ThemeService: NSObject {
    
    // MARK: - Properties
    static let shared: ThemeService = ThemeService()
    
    var isDarkModeEnabled: Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    @Storage(key: "ControlsColor", defaultValue: 2)
    private var currentColor: Int
    
    var activeColor: UIColor {
        return ColorType(rawValue: currentColor)?.color ?? ColorType.red.color
    }
    
    var currentColorType: ColorType {
        return ColorType(rawValue: currentColor) ?? ColorType.red
    }
    
    // MARK: - Methods
    func initializeService() {
        #warning("Temporary solution")
        Theme.setupAppearance()
    }
    
    func setColorType(_ colorType: ColorType) {
        currentColor = colorType.rawValue
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: ThemeDidChangeNotificationName, object: nil)
        }
        
        #warning("Temporary solution")
        let color: Theme.Color = Theme.Color(rawValue: colorType.rawValue) ?? .red
        Theme.setControlsColor(color)
    }
}
