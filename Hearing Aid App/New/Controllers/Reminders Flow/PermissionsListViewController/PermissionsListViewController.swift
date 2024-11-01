import UIKit

final class PermissionsListViewController: PMBaseViewController {
    
    enum PermissionType: Int {
        case micro
        case speechRecognition
    }

    // MARK: - Properties
    @IBOutlet private weak var closeButton: UIButton!
    
    @IBOutlet private var titleLabels: [UILabel]!
    @IBOutlet private var allowButtons: [UIButton]!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        AppConfigService.shared.analytics.track(action: .v2PermissionsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.open.rawValue])
    }
    
    // MARK: - Private methods
    private func configureUI() {
        ["The app uses a microphone to listen to everything around you while the hearing aid is working".localized(), "The app uses Speech recognition for transcribe voice".localized()].enumerated().forEach { titleLabels[$0.offset].text = $0.element }
        
        closeButton.tintColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.5)
        
        updateAllowButtons()
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.closeButton.alpha = 0.5
            }
        }
    }
    
    private func autoCloseIfNeeded() {
        updateAllowButtons()
        
        let microPermissionGranted = AudioKitService.shared.recordPermission == .granted
        
        if microPermissionGranted {
            AudioKitService.shared.initializeAudioKit()
        }
        
        guard microPermissionGranted && TranscribeService.shared.recordPermission == .authorized else {
            return
        }
        AppConfigService.shared.analytics.track(action: .v2PermissionsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.autoClose.rawValue])
        dismiss(animated: true)
    }
    
    private func updateAllowButtons() {
        allowButtons[PermissionType.micro.rawValue].setTitle(AudioKitService.shared.recordPermission == .granted ? "Allowed".localized() : "Allow".localized(), for: .normal)
        allowButtons[PermissionType.speechRecognition.rawValue].setTitle(TranscribeService.shared.recordPermission == .authorized ? "Allowed".localized() : "Allow".localized(), for: .normal)
        
        allowButtons[PermissionType.micro.rawValue].backgroundColor = AudioKitService.shared.recordPermission == .granted ? .red : UIColor.appColor(.UnactiveButton_1)
        allowButtons[PermissionType.speechRecognition.rawValue].backgroundColor = TranscribeService.shared.recordPermission == .authorized ? .red : UIColor.appColor(.UnactiveButton_1)
    }
    
    // MARK: - IBActions
    @IBAction private func allowButtonAction(_ sender: UIButton) {
        guard let type = PermissionType(rawValue: sender.tag) else {
            return
        }
        
        TapticEngine.impact.feedback(.medium)
        
        switch type {
        case .micro:
            AppConfigService.shared.analytics.track(action: .v2PermissionsScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.allow.rawValue)_\(AnalyticsAction.microphone.rawValue)"])
            
            AudioKitService.shared.requestMicrophonePermission { [weak self] _ in
                self?.autoCloseIfNeeded()
            }
        case .speechRecognition:
            AppConfigService.shared.analytics.track(action: .v2PermissionsScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.allow.rawValue)_\(AnalyticsAction.transcribe.rawValue)"])
            
            TranscribeService.shared.requestRecognitionPermission { [weak self] _ in
                self?.autoCloseIfNeeded()
            }
        }
    }
    
    @IBAction private func closeButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        dismiss(animated: true)
        
        AppConfigService.shared.analytics.track(action: .v2PermissionsScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.close.rawValue])
    }
}
