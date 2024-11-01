import UIKit

final class EmailViewController: PMBaseViewController {

    // MARK: - Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nextTitleLabel: UILabel!
    @IBOutlet private weak var skipTitleLabel: UILabel!
    
    @IBOutlet private weak var textFieldContainerView: UIView!
    @IBOutlet private weak var nextContainerView: UIView!
    
    @IBOutlet private weak var emailTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AppConfiguration.shared.analytics.track(.v2EmailScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.open.rawValue])
        AppConfiguration.shared.settings.emailScreenShown = true
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    // MARK: - Private methods
    private func configureUI() {
        nextContainerView.backgroundColor = ThemeService.shared.activeColor
        
        textFieldContainerView.layer.borderColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.6).cgColor
        textFieldContainerView.layer.borderWidth = 1.0
        
        titleLabel.text = "Thank you for joining us! Receive special offers & announcements".localized()
        
        emailTextField.placeholder = "Email address".localized()
        
        nextTitleLabel.text = "Next".localized()
        skipTitleLabel.text = "Skip".localized()
    }
    
    private func nextAction() {
        guard let text = emailTextField.text, text.isEmpty == false else {
            presentAlertPM(title: "Oops".localized(), message: "Email field can't be empty".localized())
            return
        }
        
        guard text.isValidEmail() else {
            presentAlertPM(title: "Oops".localized(), message: "Please enter a valid email".localized())
            return
        }
        
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2EmailScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.continue.rawValue])
        AppConfiguration.shared.setUserEmail(text)
        dismiss(animated: true)
    }
    
    // MARK: - IBActions
    @IBAction private func nextButtonAction(_ sender: UIButton) {
        nextAction()
    }
    
    @IBAction private func skipButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        AppConfiguration.shared.analytics.track(.v2EmailScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
        view.endEditing(true)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextAction()
        return true
    }
}
