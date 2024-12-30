import UIKit
import Speech

final class SReqVoiceRecordApViewController: UIViewController {
    //MARK: - Properties
    private var openScreenType: OpenScreenType
    
    //MARK: - @IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var allowButtonLabel: UILabel!
    
    @IBOutlet private weak var allowButtonContainerView: UIView!
    
    //MARK: - Init
    init(with openScreenType: OpenScreenType) {
        self.openScreenType = openScreenType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            UserDefaults.standard.setValue(true, forKey: CAppConstants.Keys.needsShowTranscribeOrTranslateViewController)
            UserDefaults.standard.setValue(openScreenType.rawValue, forKey: CAppConstants.Keys.showOpenScreenTypeViewController)
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
