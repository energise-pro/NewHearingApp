import UIKit

final class DTypeTextApViewController: PMUMainViewController {
    
    enum ButtonType: Int {
        case trash
        case expand
        
        var image: UIImage? {
            switch self {
            case .trash:
                return UIImage(systemName: "trash")
            case .expand:
                return UIImage(systemName: "arrow.up.left.and.arrow.down.right")
            }
        }
    }

    // MARK: - IBOutlets
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var bottomContainerView: UIView!
    @IBOutlet private weak var textFieldContainerView: UIView!
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var placeholderTextLabel: UILabel!
    
    @IBOutlet private weak var mainTextView: UITextView!
    
    @IBOutlet private var buttonImageViews: [UIImageView]!
    
    @IBOutlet private var bottomContainerHeightConstraint: NSLayoutConstraint!
    
    private var keyboardNotification = KeyboardNotification()
    private var bottomHeight: CGFloat = .zero
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainTextView.becomeFirstResponder()
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
        
        buttonImageViews.enumerated().forEach {
            $0.element.tintColor = AThemeServicesAp.shared.activeColor
            $0.element.image = ButtonType(rawValue: $0.offset)?.image
        }
        
        textFieldContainerView.backgroundColor = UIColor.appColor(.UnactiveButton_3)
        
        mainTextView.textContainerInset = .zero
        mainTextView.tintColor = AThemeServicesAp.shared.activeColor
        
        mainTextView.text = CTranscribServicesAp.shared.typeText
        configureMainLabel(asPlaceholder: CTranscribServicesAp.shared.typeText.isEmpty)
        
        keyboardNotification.keyboardWillShow = { [weak self] notification in
            guard let self = self, let userInfo = notification.userInfo,
                  let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                return
            }
            switch (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber) {
            case let (.some(duration), .some(curve)):
                let options = UIView.AnimationOptions(rawValue: curve.uintValue)
                let bottomOffset = CGPoint(x: .zero, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom + frameValue.cgRectValue.height + self.bottomHeight)
                UIView.animate(withDuration: TimeInterval(duration.doubleValue), delay: 0, options: options, animations: {
                    self.bottomContainerHeightConstraint.isActive = false
                    self.bottomContainerView.alpha = 1.0
                    
                    if bottomOffset.y > 0 {
                        self.scrollView.contentOffset = bottomOffset
                    }
                })
            default:
                break
            }
        }
        
        keyboardNotification.keyboardWillHide = { [weak self] notification in
            UIView.animate(withDuration: 0.3) {
                self?.bottomContainerView.alpha = .zero
                self?.bottomContainerHeightConstraint.isActive = true
            }
        }
    }
    
    private func configureMainLabel(asPlaceholder: Bool) {
        textLabel.textColor = asPlaceholder ? UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.5) : UIColor.appColor(.UnactiveButton_1)
        textLabel.text = asPlaceholder ? "Type quick reply".localized() : mainTextView.text
        placeholderTextLabel.text = asPlaceholder ? "" : mainTextView.text
        CTranscribServicesAp.shared.typeText = asPlaceholder ? "" : (mainTextView.text ?? "")
        
        let bottomOffset = CGPoint(x: .zero, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        bottomOffset.y > 0 ? scrollView.setContentOffset(bottomOffset, animated: true) : Void()
        
        bottomHeight = mainTextView.contentSize.height + 16.0
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        TapticEngine.impact.feedback(.medium)
        dismiss(animated: true)
        
        KAppConfigServic.shared.analytics.track(action: .v2TypeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
    
    @IBAction private func buttonsAction(_ sender: UIButton) {
        guard let buttonType = ButtonType(rawValue: sender.tag) else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        
        switch buttonType {
        case .trash:
            mainTextView.text = ""
            configureMainLabel(asPlaceholder: true)
            KAppConfigServic.shared.analytics.track(action: .v2TypeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.clearText.rawValue])
        case .expand:
            mainTextView.resignFirstResponder()
            KAppConfigServic.shared.analytics.track(action: .v2TypeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.expand.rawValue])
        }
    }
    
    @IBAction private func tapGestureAction(_ sender: UITapGestureRecognizer) {
        _ = keyboardNotification.isKeyboardOpened ? mainTextView.resignFirstResponder() : mainTextView.becomeFirstResponder()
        
        let stringState = keyboardNotification.isKeyboardOpened ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
        KAppConfigServic.shared.analytics.track(action: .v2TypeScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.type.rawValue)_\(stringState)"])
    }
}

// MARK: - UITextViewDelegate
extension DTypeTextApViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else {
            configureMainLabel(asPlaceholder: true)
            return
        }
        configureMainLabel(asPlaceholder: text.isEmpty)
    }
}
