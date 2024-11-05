import UIKit
import Speech

final class SReqVoiceRecordApViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var allowButton: UIButton!
    @IBOutlet private weak var closeImageView: UIImageView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConfiguration.shared.analytics.track(.v2VoiceRecordingReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
        configureUI()
    }
    
    //MARK: - Function
    private func configureUI() {
        closeImageView.tintColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.3)
        titleLabel.textColor = UIColor.appColor(.UnactiveButton_1)
        descriptionLabel.textColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.8)
        
        let fontMultiplier: CGFloat = 0.03
        let titleFontSize = min(max(.appHeight * fontMultiplier, Defaults.minimumTitleFontSize), Defaults.maximumTitleFontSize)
        let descriptionFontSize = min(max(.appHeight * fontMultiplier, Defaults.minimumDescriptionFontSize), Defaults.maximumDescriptionFontSize)

        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .bold)
        descriptionLabel.font = UIFont.systemFont(ofSize: descriptionFontSize, weight: .medium)
        
        titleLabel.text = "Allow Speech recognition function".localized()
        descriptionLabel.text = "Dear User, for use Speech recognition function, you need to allow permission".localized()
        allowButton.setTitle("Continue".localized(), for: .normal)
        allowButton.backgroundColor = ThemeService.shared.activeColor
    }
    
    //MARK: @IBAction
    @IBAction private func allowButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2VoiceRecordingReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.allow.rawValue])
        if let appSettingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction private func closeButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2VoiceRecordingReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - IAppStateListener
extension SReqVoiceRecordApViewController: IAppStateListener {
    
    func appWillEnterForeground() {
        if SFSpeechRecognizer.authorizationStatus() == .authorized {
            AppConfiguration.shared.analytics.track(.v2VoiceRecordingReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
            dismiss(animated: true, completion: nil)
        }
    }
}

private struct Defaults {
    static let minimumTitleFontSize: CGFloat = 22.0
    static let maximumTitleFontSize: CGFloat = 28.0
    
    static let minimumDescriptionFontSize: CGFloat = 16.0
    static let maximumDescriptionFontSize: CGFloat = 25.0
}
