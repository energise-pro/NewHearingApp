import UIKit

final class PreOnboardingViewController: UIViewController {
    
    enum QuestionType: Int {
        case hearing
        case listening
        case transcribe
        
        var title: String {
            switch self {
            case .hearing:
                return "Hearing Aid".localized()
            case .listening:
                return "Listening device".localized()
            case .transcribe:
                return "Transcribe".localized()
            }
        }
        
        var analyticAction: AnalyticsAction {
            switch self {
            case .hearing:
                return .hearing
            case .listening:
                return .listening
            case .transcribe:
                return .transcribe
            }
        }
    }

    // MARK: - Properties
    @IBOutlet private weak var introContainerView: UIView!
    @IBOutlet private weak var questionsContainerView: UIView!
    @IBOutlet private weak var nextContainerView: UIView!
    
    @IBOutlet private weak var introTitleLabel: UILabel!
    @IBOutlet private weak var petalTitleLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    
    @IBOutlet private weak var appIconImageView: UIImageView!
    @IBOutlet private weak var questionBackgroundImageView: UIImageView!
    
    @IBOutlet private var petalImageViews: [UIImageView]!
    
    @IBOutlet private var questionTitleLabels: [UILabel]!
    
    @IBOutlet private var verticalGradientView: [UIView]?
    @IBOutlet private var reverseVerticalGradientView: [UIView]?
    @IBOutlet private var questionContainerViews: [UIView]!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConfigService.shared.analytics.track(.v2PreOnboardingScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.open.rawValue])
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPulseAnimation()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layoutIfNeeded()
        verticalGradientView?.forEach { $0.addGradient([UIColor.systemBackground, UIColor.systemBackground.withAlphaComponent(0.4)], isHorizontal: false) }
        reverseVerticalGradientView?.forEach { $0.addGradient([UIColor.systemBackground.withAlphaComponent(0.4), UIColor.systemBackground], isHorizontal: false) }
    }
    
    // MARK: - Private methods
    private func configureUI() {
        nextContainerView.backgroundColor = ThemeService.shared.activeColor
        
        petalImageViews.forEach { $0.tintColor = ThemeService.shared.activeColor }
        
        questionContainerViews.forEach { $0.backgroundColor = ThemeService.shared.activeColor }
        
        questionTitleLabels.enumerated().forEach { $0.element.text = QuestionType(rawValue: $0.offset)?.title }
        
        petalImageViews.last?.image = petalImageViews.last?.image?.withHorizontallyFlippedOrientation()
        questionBackgroundImageView.image = questionBackgroundImageView.image?.withHorizontallyFlippedOrientation()
        appIconImageView.image = Constants.Images.icAppIcon
        
        introTitleLabel.text = "The best hearing audio services together in one app".localized()
        questionTitleLabel.text = "Which feature is the most interesting for you?".localized()
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: "108,540\n", attributes: [.font: UIFont.systemFont(ofSize: 24.0, weight: .bold)]))
        attributedString.append(NSAttributedString(string: "%@ people use every day".localized(with: [""]), attributes: [.font: UIFont.systemFont(ofSize: 22.0, weight: .regular)]))
        
        petalTitleLabel.attributedText = attributedString
    }
    
    private func startPulseAnimation() {
        nextContainerView.startPulse(withType: .multiRadar, color: ThemeService.shared.activeColor, pulseCount: 6, frequency: 0.1, radius: 50.0, andDuration: 3.0)
    }
    
    private func animateShowQuestionView() {
        introContainerView.animateHidden(true)
        questionsContainerView.animateHidden(false)
    }
    
    // MARK: - Actions
    @IBAction private func nextButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        animateShowQuestionView()
        AppConfigService.shared.analytics.track(.v2PreOnboardingScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.continue.rawValue])
    }
    
    @IBAction private func questionButtonAction(_ sender: UIButton) {
        guard let type = QuestionType(rawValue: sender.tag) else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        AppConfigService.shared.analytics.track(.v2PreOnboardingScreen, with: [AnalyticsAction.action.rawValue: type.analyticAction.rawValue])
        NavigationManager.shared.setOnboardingAsRootViewController()
    }
}
