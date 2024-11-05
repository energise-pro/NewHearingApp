import UIKit

final class HMicrophPermisApViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var allowButtonLabel: UILabel!
    
    @IBOutlet private weak var allowButtonContainerView: UIView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        KAppConfigServic.shared.analytics.track(.v2MicrophoneReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
        configureUI()
    }
    
    //MARK: - IBActions
    @IBAction private func allowButtonAction(_ sender: UIButton) {
        KAppConfigServic.shared.analytics.track(.v2MicrophoneReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.allow.rawValue])
        TapticEngine.impact.feedback(.medium)
        SAudioKitServicesAp.shared.requestMicrophonePermission { [weak self] accepted in
            accepted ? self?.dismiss(animated: true) : Void()
        }
    }
    
    @IBAction private func latterButtonAction(_ sender: UIButton) {
        KAppConfigServic.shared.analytics.track(.v2MicrophoneReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
        TapticEngine.impact.feedback(.medium)
        dismiss(animated: true)
    }
    
    //MARK: - Private methods
    private func configureUI() {
        titleLabel.textColor = UIColor.appColor(.UnactiveButton_1)
        descriptionLabel.textColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.8)
        allowButtonLabel.textColor = .white
        
        titleLabel.text = "Please Allow Microphone Usage".localized()
        descriptionLabel.text = "Dear User, for correctly work with our app, we need your microphone usage permission".localized()
        allowButtonLabel.text = "Continue".localized()
        
        allowButtonContainerView.backgroundColor = AThemeServicesAp.shared.activeColor
        
        let fontMultiplier: CGFloat = 0.03
        let titleFontSize = min(max(.appHeight * fontMultiplier, Defaults.Sizes.minimumTitleFontSize), Defaults.Sizes.maximumTitleFontSize)
        let descriptionFontSize = min(max(.appHeight * fontMultiplier, Defaults.Sizes.minimumDescriptionFontSize), Defaults.Sizes.maximumDescriptionFontSize)
        
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .bold)
        descriptionLabel.font = UIFont.systemFont(ofSize: descriptionFontSize, weight: .medium)
    }
}

private struct Defaults {
    
    struct Sizes {
        static let minimumTitleFontSize: CGFloat = 22.0
        static let maximumTitleFontSize: CGFloat = 28.0
        
        static let minimumDescriptionFontSize: CGFloat = 16.0
        static let maximumDescriptionFontSize: CGFloat = 25.0
    }
}
