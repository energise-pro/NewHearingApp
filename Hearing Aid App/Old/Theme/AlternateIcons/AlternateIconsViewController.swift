//
//  AlternateIconsViewController.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 2/2/21.
//
import UIKit

private enum Icon: String, CaseIterable {
    
    case primary = ""
    case orangeGradient = "GradientOrange-Icon"
    case orange = "Orange-Icon"
    case lightBlue = "LightBlue-Icon"
    case blue = "Blue-Icon"
    
    var analyticAction: AnalyticsAction {
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

    var isSelected: Bool {
        if let alternateIconName = UIApplication.shared.alternateIconName {
            return self.rawValue == alternateIconName
        } else {
            return self == .primary
        }
    }
}

protocol AlternateIconsViewControllerDelegate: AnyObject {
    func dismiss()
}

final class AlternateIconsViewController: BasePopoverViewController {

    @IBOutlet fileprivate var defaultIcon: IconView!
    @IBOutlet fileprivate var purpuleIcon: IconView!
    @IBOutlet fileprivate var orangeIcon: IconView!
    @IBOutlet fileprivate var redIcon: IconView!
    @IBOutlet fileprivate var blueIcon: IconView!

    @IBOutlet weak var closeButton: UIButton!

    private var icons: [IconView] {
        return [defaultIcon,purpuleIcon,orangeIcon,redIcon,blueIcon]
    }
    
    weak var delegate: AlternateIconsViewControllerDelegate?
    
    private var indexIcon = 0

    @IBOutlet fileprivate var bgBlurView: UIVisualEffectView?

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.tintColor = Theme.buttonInactiveColor
        reload()
        icons.forEach { icon in
            icon.iconButton.layer.cornerRadius = 10
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layer.borderWidth = 2
        view.layer.borderColor = Theme.buttonInactiveColor.withAlphaComponent(0.5).cgColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
    }

    private func reload() {
        for (index, icon) in Icon.allCases.enumerated() {
            icons[safe:index]?.icon = icon
        }
    }

    private func setAlternate(icon: Icon) {
        guard icon.isSelected == false,
              UIApplication.shared.supportsAlternateIcons else { return }
        let iconName: String? = icon == .primary ? nil : icon.rawValue
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                presentError(error: error)
                return
            }
        }
        delegate?.dismiss()
        remove()
    }

    @IBAction func changeIconAction(sender: UIButton) {
        guard let iconView = sender.superview as? IconView,
              let icon = iconView.icon else { return }
        setAlternate(icon: icon)
        
        AppConfigService.shared.analytics.track(action: .v2SettingsScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.changeAppIcon.rawValue)_\(icon.analyticAction.rawValue)"])
    }

    @IBAction func closeAction(sender:UIButton) {
        delegate?.dismiss()
        remove()
    }
}

final class IconView: SpringView {

    @IBOutlet weak var checkmarkIcon: UIImageView!

    @IBOutlet weak var iconButton: UIButton!

    fileprivate var icon: Icon? {
        didSet {
            if let image = icon?.previewImage {
                iconButton.setBackgroundImage(image, for: .normal)
            }
            checkmarkIcon.isHidden = icon?.isSelected == false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkIcon.tintColor = Theme.buttonActiveColor
        checkmarkIcon.isHidden = true
    }

    @IBAction func buttonAction() {
        animate(name: "pop")
    }
}
