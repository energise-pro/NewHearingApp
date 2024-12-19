import UIKit
import Speech

final class SReqVoiceRecordApViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var allowButtonLabel: UILabel!
    
    @IBOutlet private weak var allowButtonContainerView: UIView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        KAppConfigServic.shared.analytics.track(.v2VoiceRecordingReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
        configureUI()
    }
    
    //MARK: - Function
    private func configureUI() {
        titleLabel.textColor = UIColor.appColor(.White100)
        descriptionLabel.textColor = UIColor.appColor(.White100)
        allowButtonLabel.textColor = UIColor.appColor(.Purple100)
        
        titleLabel.text = "Allow Speech Recognition".localized()
        descriptionLabel.text = "Please allow speech recognition to use the transcription feature.".localized()
        allowButtonLabel.text = "Go to Settings".localized()
    }
    
    //MARK: @IBAction
    @IBAction private func allowButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
//        KAppConfigServic.shared.analytics.track(.v2VoiceRecordingReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.allow.rawValue])
        if let appSettingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction private func closeButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
//        KAppConfigServic.shared.analytics.track(.v2VoiceRecordingReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - SIAppStateListeners
extension SReqVoiceRecordApViewController: SIAppStateListeners {
    
    func appWillEnterForeground() {
        if SFSpeechRecognizer.authorizationStatus() == .authorized {
//            KAppConfigServic.shared.analytics.track(.v2VoiceRecordingReminder, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
            dismiss(animated: true, completion: nil)
        }
    }
}
