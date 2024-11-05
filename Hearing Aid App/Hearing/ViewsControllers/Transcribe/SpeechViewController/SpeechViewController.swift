import UIKit

final class SpeechViewController: PMUMainViewController {

    enum BottomButtonType: Int, CaseIterable {
        case type
        case transcribe
        case translate
        
        var image: UIImage? {
            switch self {
            case .translate:
                return CAppConstants.Images.icGlobe
            case .type:
                return CAppConstants.Images.icKeyboard
            case .transcribe:
                return UIImage.init(systemName: "mic.circle")
            }
        }
        
        var title: String {
            switch self {
            case .translate:
                return "Translate".localized()
            case .type:
                return "Type".localized()
            case .transcribe:
                return "Transcribe".localized()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var infoContainerView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var instructionLabel: UILabel!
    @IBOutlet private weak var bookmarksTitleLabel: UILabel!
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var bookmarksImageView: UIImageView!
    @IBOutlet private weak var infoImageView: UIImageView!
    
    @IBOutlet private var bottomImageViews: [UIImageView]!
    @IBOutlet private var bottomLabels: [UILabel]!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        infoContainerView.layoutIfNeeded()
        infoContainerView.dropShadow(color: UIColor.label, opacity: 0.15, offSet: CGSize(width: .zero, height: 4.0), radius: 8.0, scale: true)
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        updateMainColors()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        BottomButtonType.allCases.enumerated().forEach { index, buttonType in
            bottomImageViews[index].image = buttonType.image
            bottomLabels[index].text = buttonType.title
            
            bottomImageViews[index].tintColor = UIColor.appColor(.UnactiveButton_1)
            bottomLabels[index].textColor = UIColor.appColor(.UnactiveButton_1)
        }
        
        bookmarksTitleLabel.textColor =  UIColor.appColor(.UnactiveButton_1)
        bookmarksImageView.tintColor = UIColor.appColor(.UnactiveButton_1)
        
        titleLabel.text = "Tap the mic to get started ;)".localized()
        instructionLabel.text = "Instruction".localized()
        bookmarksTitleLabel.text = "Saved".localized()
        
        bookmarksImageView.image = CAppConstants.Images.icFolder
        infoImageView.image = UIImage.init(systemName: "info.circle")
        logoImageView.image = CAppConstants.Images.icLogo
        
        updateMainColors()
    }
    
    private func updateMainColors() {
        [infoImageView, logoImageView].forEach { $0?.tintColor = ThemeService.shared.activeColor }
    }
    
    // MARK: - IBActions
    @IBAction private func bottomButtonsAction(_ sender: UIButton) {
        guard let buttonType = BottomButtonType(rawValue: sender.tag) else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch buttonType {
        case .translate:
            AppsNavManager.shared.presentTranslateViewController()
            AppConfiguration.shared.analytics.track(action: .v2TranscribeMainScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.translate.rawValue])
        case .type:
            AppsNavManager.shared.presentTypeTextViewController()
            AppConfiguration.shared.analytics.track(action: .v2TranscribeMainScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.type.rawValue])
        case .transcribe:
            AppsNavManager.shared.presentTranscribeViewController()
            AppConfiguration.shared.analytics.track(action: .v2TranscribeMainScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.transcribe.rawValue])
        }
    }
    
    @IBAction private func bookmarkButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppsNavManager.shared.presentTranscriptsListViewController()
        AppConfiguration.shared.analytics.track(action: .v2TranscribeMainScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.saved.rawValue])
    }
    
    @IBAction private func instructionButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppsNavManager.shared.presentVideoFInstructApViewController(with: CAppConstants.URLs.transcrabeInstructions)
    }
}
