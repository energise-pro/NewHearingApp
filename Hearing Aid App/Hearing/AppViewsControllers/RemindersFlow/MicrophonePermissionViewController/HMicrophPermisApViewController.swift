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
        titleLabel.textColor = UIColor.appColor(.White100)
        descriptionLabel.textColor = UIColor.appColor(.White100)
        allowButtonLabel.textColor = UIColor.appColor(.Purple100)
        
        titleLabel.text = "Allow Microphone Usage".localized()
        descriptionLabel.text = "Please allow microphone usage for sound recognition and hearing aid.".localized()
        allowButtonLabel.text = "Go to Settings".localized()
    }
}
