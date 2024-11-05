import UIKit

final class ZAppIconViewController: PMUMainViewController {
    
    // MARK: - Properties
    @IBOutlet private var previewsImageViews: [UIImageView]!
    
    @IBOutlet private var opacityViews: [UIView]!
    
    private var selectedIcon: IconType {
        return IconType(rawValue: UIApplication.shared.alternateIconName ?? "") ?? .primary
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Actions
    @IBAction private func tapGestureAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @IBAction private func buttonAction(_ sender: UIButton) {
        guard let iconType = IconType.allCases[safe: sender.tag] else {
            return
        }
        
        TapticEngine.impact.feedback(.medium)
        
        let iconName = iconType == .primary ? nil : iconType.rawValue
        UIApplication.shared.setAlternateIconName(iconName)
        configureUI()
        AppConfiguration.shared.settings.presentAppRatingAlert()
        
        AppConfiguration.shared.analytics.track(action: .v2SettingsScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.changeAppIcon.rawValue)_\(iconType.analyticAction.rawValue)"])
    }
    
    // MARK: - Private methods
    private func configureUI() {
        previewsImageViews.enumerated().forEach {
            $0.element.image = IconType.allCases[$0.offset].previewImage
            $0.element.layer.borderColor = UIColor.appColor(.UnactiveButton_2)?.cgColor
            $0.element.layer.borderWidth = IconType.allCases[$0.offset] == selectedIcon ? 2.0 : 0.0
            opacityViews[$0.offset].isHidden = IconType.allCases[$0.offset] == selectedIcon
        }
        opacityViews.forEach {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    }
}

enum IconType: String, CaseIterable {
    case primary = ""
    case orangeGradient = "GradientOrange-Icon"
    case orange = "Orange-Icon"
    case lightBlue = "LightBlue-Icon"
    case blue = "Blue-Icon"
    
    var analyticAction: GAppAnalyticActions {
        switch self {
        case .primary:
            return .red
        case .orangeGradient:
            return .gradientOrange
        case .orange:
            return .orange
        case .lightBlue:
            return .lightBlue
        case .blue:
            return .blue
        }
    }
    
    var previewImage: UIImage? {
        return UIImage(named: "\(self.rawValue)-Preview") ?? UIImage(named: "AppIcon-Preview")
    }
}
