import UIKit

final class GOnbBSpeechViewCell: UICollectionViewCell {

    //MARK: - @IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var typographyLabel: CLTypingLabel!
    @IBOutlet private weak var translateTypographyLabel: CLTypingLabel!
    
    @IBOutlet private weak var handImageView: UIImageView!
    
    @IBOutlet private weak var continueButton: UIButton!
    
    @IBOutlet private weak var topContainerLabelsConstraint: NSLayoutConstraint!
    @IBOutlet private weak var spasingLabelsConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leftImageViewHandConstraint: NSLayoutConstraint!
    @IBOutlet private weak var typographyLabelTopConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    private weak var delegate: JOnbrdCollectViewCellDelegate?
    private var onboardingType: TOnboardHvTabs?
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        translateTypographyLabel.isHidden = true
    }

    //MARK: - Function
    func configureCell(model: GOnboModelCollectionViewCell) {
        onboardingType = model.onboardingType
        titleLabel.text = model.onboardingType.title
        descriptionLabel.text = model.onboardingType.description
        handImageView.image = model.onboardingType.icon
        delegate = model.delegate
        configureUI()
    }
    
    func startTypographyAnimation() {
        typographyLabel.continueTyping()
        translateTypographyLabel.continueTyping()
    }
    
    func pauseTypographyAnimation() {
        typographyLabel.pauseTyping()
        translateTypographyLabel.pauseTyping()
    }
    
    private func configureUI() {
        titleLabel.textColor = UIColor.appColor(.UnactiveButton_1)
        descriptionLabel.textColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.7)
        continueButton.setTitle("Continue".localized(), for: .normal)
        continueButton.backgroundColor = ThemeService.shared.activeColor
        
        let typographyFontSize = min(max(.appHeight * 0.03, 15), 18)
        [typographyLabel, translateTypographyLabel].forEach {
            $0?.font = UIFont.SFProDisplay.mediumItalic(typographyFontSize)
            $0?.charInterval = 0.08
        }
        
        let topTypographyText = onboardingType == .speachRecognition ? "Transcribes in real-time. Text appears on your phone as words are spoken.".localized() : "¡Habla con el mundo!"
        typographyLabel.text = topTypographyText
        typographyLabel.pauseTyping()
        typographyLabel.onTypingAnimationFinished = { [weak self] in
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                self?.typographyLabel.text = topTypographyText
            }
        }
        
        if onboardingType == .speechTranslate {
            translateTypographyLabel.isHidden = false
            translateTypographyLabel.text = "Speak with the world!"
            translateTypographyLabel.pauseTyping()
            translateTypographyLabel.onTypingAnimationFinished = { [weak self] in
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                    self?.translateTypographyLabel.text = "Speak with the world!"
                }
            }
        }
        
        let fontMultiplier: CGFloat = 0.03
        let titleFontSize = min(max(.appHeight * fontMultiplier, 18), 24)
        let descriptionFontSize = min(max(.appHeight * fontMultiplier, 14), 20)
        titleLabel.font = titleLabel.font.withSize(titleFontSize)
        descriptionLabel.font = descriptionLabel.font.withSize(descriptionFontSize)
        topContainerLabelsConstraint.constant = min(max(.appHeight * 0.09, 45), 70)
        spasingLabelsConstraint.constant = min(max(.appHeight * 0.03, 15), 20)
    }
    
    //MARK: - @IBAction
    @IBAction private func continueButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.heavy)
        delegate?.tapContinueButton()
    }
}
