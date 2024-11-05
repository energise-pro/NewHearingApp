import UIKit

struct Theme {
    private init() {}

    enum Color: Int, CaseIterable {
        case purpule, orange, red, blue, green

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

        var gradientColors: [UIColor] {
            switch self {
            case .purpule:
                return [#colorLiteral(red: 1, green: 0, blue: 0.9607843137, alpha: 1), #colorLiteral(red: 0.4862745098, green: 0.2509803922, blue: 0.8, alpha: 1)]
            case .orange:
                return [#colorLiteral(red: 1, green: 0.7803921569, blue: 0, alpha: 1), #colorLiteral(red: 0.9294117647, green: 0.1019607843, blue: 0.1019607843, alpha: 1)]
            case .red:
                return [#colorLiteral(red: 1, green: 0.5137254902, blue: 0, alpha: 1), #colorLiteral(red: 0.9294117647, green: 0.1019607843, blue: 0.1019607843, alpha: 1)]
            case .blue:
                return [#colorLiteral(red: 0, green: 1, blue: 0.8784313725, alpha: 1), #colorLiteral(red: 0, green: 0.4, blue: 1, alpha: 1)]
            case .green:
                return [#colorLiteral(red: 0.8588235294, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 0.07843137255, green: 0.8117647059, blue: 0.1529411765, alpha: 1)]
            }
        }

        var gradientInactiveColors: [UIColor] {
            return [buttonInactiveColor, buttonInactiveColor]
        }
        
        var titleAnalysticsColor: String {
            switch self {
            case .blue:
                return GAppAnalyticActions.blue.rawValue
            case .purpule:
                return GAppAnalyticActions.violet.rawValue
            case .orange:
                return GAppAnalyticActions.orange.rawValue
            case .red:
                return GAppAnalyticActions.red.rawValue
            case .green:
                return GAppAnalyticActions.green.rawValue
            }
        }
    }

    static var current: Color = .red

    static func setupAppearance() {
        let theme = Color(rawValue: AThemeServicesAp.shared.currentColorType.rawValue) ?? .red
        current = theme
        buttonActiveColor = theme.color

        UITabBar.appearance().tintColor = Theme.buttonActiveColor
        UITabBar.appearance().unselectedItemTintColor = Theme.buttonInactiveColor
        UIButton.appearance().tintColor = Theme.buttonActiveColor
    }

    static private(set) var buttonActiveColor = current.color

    static let buttonInactiveColor: UIColor = UIColor(named: "textColor") ?? UIColor.systemGray

    static var enableDarkMode: Bool = false

    static func setControlsColor(_ color: Color) {
        current = color
        buttonActiveColor = color.color
        setupAppearance()
    }
}
