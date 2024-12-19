import UIKit

final class DTypeTextApViewController: PMUMainViewController {
    
    enum ButtonType: Int {
        case trash
        case expand
        
        var image: UIImage? {
            switch self {
            case .trash:
                return UIImage(named: "trashIcon")
            case .expand:
                return UIImage(named: "arrowsOutIcon")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KAppConfigServic.shared.analytics.track(.typeScreenClosed, with: [
            "text_presence" : !CTranscribServicesAp.shared.typeText.isEmpty
        ])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
//        navigationItem.rightBarButtonItem?.tintColor = AThemeServicesAp.shared.activeColor
    }
    
    // MARK: - Private methods
    private func configureUI() {
        overrideUserInterfaceStyle = .light
        
        setupRightBarButton()
        navigationController?.navigationBar.barTintColor = UIColor.appColor(.White100)!
        
        buttonImageViews.enumerated().forEach {
            $0.element.tintColor = UIColor.appColor(.Red100)
            $0.element.image = ButtonType(rawValue: $0.offset)?.image
        }
        
        textFieldContainerView.backgroundColor = UIColor.appColor(.Purple20)
        
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
        
        KAppConfigServic.shared.analytics.track(.typeScreenOpened, with: [
            "text_presence" : !CTranscribServicesAp.shared.typeText.isEmpty
        ])
    }
    
    private func setupRightBarButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close".localized(), for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        closeButton.setTitleColor(UIColor.appColor(.Red100), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }
    
    private func setupLeftBarButton() {
        let buttonItem = UIBarButtonItem(image:  UIImage(named: "arrowsInIcon"), style: .plain, target: self, action: #selector(arrowsInButtonAction))
        navigationItem.leftBarButtonItems = keyboardNotification.isKeyboardOpened ? nil : [buttonItem]
    }
    
    private func configureMainLabel(asPlaceholder: Bool) {
        textLabel.textColor = asPlaceholder ? UIColor.appColor(.Grey100) : UIColor.appColor(.Purple100)
        textLabel.text = asPlaceholder ? "Enter text".localized() : mainTextView.text
        textLabel.textAlignment = asPlaceholder ? .center : .left
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
        
        KAppConfigServic.shared.analytics.track(.typeScreenClosed, with: [
            "text_presence" : !CTranscribServicesAp.shared.typeText.isEmpty
        ])
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
            KAppConfigServic.shared.analytics.track(action: .delete, with: [
                "object" : GAppAnalyticActions.type.rawValue
            ])
        case .expand:
            mainTextView.resignFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.setupLeftBarButton()
            }
            
            KAppConfigServic.shared.analytics.track(action: .typeAreaExpanded)
        }
    }
    
    @IBAction private func tapGestureAction(_ sender: UITapGestureRecognizer) {
        _ = keyboardNotification.isKeyboardOpened ? mainTextView.resignFirstResponder() : mainTextView.becomeFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.setupLeftBarButton()
        }
        
//        let stringState = keyboardNotification.isKeyboardOpened ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
//        KAppConfigServic.shared.analytics.track(action: .v2TypeScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.type.rawValue)_\(stringState)"])
    }
    
    @objc private func arrowsInButtonAction() {
        navigationItem.leftBarButtonItems = nil
        mainTextView.becomeFirstResponder()
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
