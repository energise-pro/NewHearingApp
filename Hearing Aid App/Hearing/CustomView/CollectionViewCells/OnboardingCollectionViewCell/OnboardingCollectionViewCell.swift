import UIKit

protocol OnboardingCollectionViewCellDelegate: AnyObject {
    
    func tapBeforeButton(from cell: OnboardingCollectionViewCell)
    func tapAfterButton(from cell: OnboardingCollectionViewCell)
    func tapContinueButton()
}

enum OnboardingButtons {
    case after
    case before
}

final class OnboardingCollectionViewCell: UICollectionViewCell {

    //MARK: - @IBOutlet
    @IBOutlet private weak var buttonsContainerView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var afterTitleLabel: UILabel!
    @IBOutlet private weak var beforeTitleLabel: UILabel!
    
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var leftButtonImageView: UIImageView!
    @IBOutlet private weak var rightButtonImageView: UIImageView!
    @IBOutlet private weak var appIconImageView: UIImageView!
    
    @IBOutlet private weak var continueButton: UIButton!
    
    @IBOutlet private weak var topContainerLabelsConstraint: NSLayoutConstraint!
    @IBOutlet private weak var spasingLabelsConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomButtonConstraint: NSLayoutConstraint!
    @IBOutlet private weak var continueBottomConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    private weak var delegate: OnboardingCollectionViewCellDelegate?
    private var duplicateLeftView: UIView?
    
    //MARK: - Functions
    override func prepareForReuse() {
        super.prepareForReuse()
        buttonsContainerView.stopPulseAnimation()
    }
    
    func configureCell(model: GOnboModelCollectionViewCell) {
        titleLabel.text = model.onboardingType.title
        descriptionLabel.text = model.onboardingType.description
        thumbnailImageView.image = model.onboardingType.icon
        delegate = model.delegate
        configureUI()
        buttonsContainerView.pulseAnimation()
    }
    
    func setDefaultStatesForButtons() {
        updateStateButton(asActive: false, button: .after)
        updateStateButton(asActive: false, button: .before)
    }
    
    func triggerAfterButtonAction() {
        setDefaultStatesForButtons()
        updateStateButton(asActive: false, button: .before)
        updateStateButton(asActive: true, button: .after)
        delegate?.tapAfterButton(from: self)
    }
    
    private func configureUI() {
        appIconImageView.image = CAppConstants.Images.icAppIcon
        titleLabel.textColor = UIColor.appColor(.UnactiveButton_1)
        descriptionLabel.textColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.7)
        beforeTitleLabel.text = "Before".localized()
        afterTitleLabel.text = "After".localized()
        continueButton.setTitle("Continue".localized(), for: .normal)
        continueButton.backgroundColor = ThemeService.shared.activeColor
        
        let fontMultiplier: CGFloat = 0.03
        let titleFontSize = min(max(.appHeight * fontMultiplier, 18), 24)
        let descriptionFontSize = min(max(.appHeight * fontMultiplier, 14), 20)
        titleLabel.font = titleLabel.font.withSize(titleFontSize)
        descriptionLabel.font = descriptionLabel.font.withSize(descriptionFontSize)
        topContainerLabelsConstraint.constant = min(max(.appHeight * 0.09, 45), 70)
        spasingLabelsConstraint.constant = min(max(.appHeight * 0.027, 15), 20)
        bottomButtonConstraint.constant = min(max(.appHeight * 0.05, 30), 45)
        continueBottomConstraint.constant = min(max(.appHeight * 0.049, 30), 40)
        setDefaultStatesForButtons()
    }
    
    func updateStateButton(asActive: Bool, button: OnboardingButtons) {
        switch button {
        case .after:
            afterTitleLabel.textColor = asActive ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
            rightButtonImageView.tintColor = asActive ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
        case .before:
            beforeTitleLabel.textColor = asActive ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
            leftButtonImageView.tintColor = asActive ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_2)
        }
    }
    
    //MARK: - @IBAction
    @IBAction private func continueButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.heavy)
        delegate?.tapContinueButton()
    }
    
    @IBAction private func beforeButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        updateStateButton(asActive: true, button: .before)
        updateStateButton(asActive: false, button: .after)
        delegate?.tapBeforeButton(from: self)
    }
    
    @IBAction private func afterButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        triggerAfterButtonAction()
    }
}
