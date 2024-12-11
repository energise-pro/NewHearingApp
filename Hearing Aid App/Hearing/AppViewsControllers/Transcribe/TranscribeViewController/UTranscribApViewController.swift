import UIKit

final class UTranscribApViewController: PMUMainViewController {
    
    enum BottomButtonType: Int, CaseIterable {
        case clear
        case save
        case transcribe
        case setup
        case flip
        
        var image: UIImage? {
            switch self {
            case .clear:
                return UIImage(named: "trashFilledIcon")
            case .save:
                return UIImage(named: "saveFilledIcon")
            case .transcribe:
                return UIImage(named: "micButtonOffIcon")
            case .flip:
                return UIImage(named: "flipIcon")
            case .setup:
                return UIImage(named: "textIcon")
            }
        }
        
        var title: String {
            switch self {
            case .clear:
                return "Delete".localized()
            case .save:
                return "Save".localized()
            case .transcribe:
                return "Transcribe".localized()
            case .flip:
                return "Flip".localized()
            case .setup:
                return "Text".localized()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var mainTextView: UITextView!
    
    @IBOutlet private weak var placeholderLabel: UILabel!
    
    @IBOutlet private weak var microphoneButton: UIButton!
    
    @IBOutlet private var bottomImageViews: [UIImageView]!
    @IBOutlet private var bottomLabels: [UILabel]!
    
    @IBOutlet private weak var placeholderLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var placeholderLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomBackgroundView: UIView!
    
    private var keyboardNotification = KeyboardNotification()
    private(set) var notAskConfirmationForDeleteAction: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "notAskConfirmationForDeleteAction")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "notAskConfirmationForDeleteAction")
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        CTranscribServicesAp.shared.chargeRecognation()
        configureUI()
        bottomButtonsAction(microphoneButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CTranscribServicesAp.shared.isStartedTranscribe ? changeTranscribeState(isHapticEnabled: false) : Void()
        SAudioKitServicesAp.shared.switchAudioEngine(.aid)
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        guard motion == .motionShake, CTranscribServicesAp.shared.isShakeToClear else {
            return
        }
        clearAction()
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.clearText.rawValue])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        [navigationItem.leftBarButtonItem, navigationItem.rightBarButtonItem].forEach { $0?.tintColor = AThemeServicesAp.shared.activeColor }
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = CTranscribServicesAp.shared.localizedSelectedLocale.components(separatedBy: " ").first?.capitalized
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appColor(.Purple100)!]
        let shareButtonItem = UIBarButtonItem(image: UIImage(named: "shareButtonIcon"), style: .plain, target: self, action: #selector(shareButtonAction))
        navigationItem.leftBarButtonItem = shareButtonItem
        navigationController?.navigationBar.barTintColor = UIColor.appColor(.White100)!
        setupRightBarButton()
        
        BottomButtonType.allCases.enumerated().forEach { index, buttonType in
            bottomImageViews[index].image = buttonType.image
            bottomLabels[index].text = buttonType.title
            
            bottomImageViews[index].tintColor = UIColor.appColor(.White100)
            bottomLabels[index].textColor = UIColor.appColor(.White100)
        }
        
        let clearButton = UIBarButtonItem(image: UIImage(named: "trashIcon"), style: .plain, target: self, action: #selector(clearButtonAction))
        let copyAllButton = UIBarButtonItem(title: "Copy all".localized(), style: .plain, target: self, action: #selector(copyAllButtonAction))
        let saveButton = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(saveButtonAction))
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneButtonAction))
        mainTextView.addActionBar(with: [clearButton, copyAllButton, saveButton, doneButton])
        
        placeholderLabel.text = "Tap the Mic button below to get started".localized()
        placeholderLabel.textColor = UIColor.appColor(.Grey100)
        
        mainTextView.tintColor = AThemeServicesAp.shared.activeColor
        
        if !CTranscribServicesAp.shared.transcribeText.isEmpty {
            mainTextView.text = CTranscribServicesAp.shared.transcribeText
            textViewDidChange(mainTextView)
            CTranscribServicesAp.shared.insertToDictionary(new: CTranscribServicesAp.shared.transcribeText)
        }
        
        CTranscribServicesAp.shared.availabilityRecognition = { [weak self] available in
            DispatchQueue.main.async {
                self?.placeholderLabel.text = CTranscribServicesAp.shared.recordPermission == .notDetermined ? "Allow speech recognition".localized() : "Recognition not available".localized()
            }
        }
        
        keyboardNotification.keyboardWillShow = { [weak self] _ in
            CTranscribServicesAp.shared.isStartedTranscribe ? self?.changeTranscribeState(isHapticEnabled: false) : Void()
        }
        
        updateFonts()
        
        bottomBackgroundView.layer.cornerRadius = 12
        bottomBackgroundView.layer.cornerCurve = .continuous
        bottomBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomBackgroundView.backgroundColor = UIColor.appColor(.Purple100)
    }
    
    private func setupRightBarButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close".localized(), for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        closeButton.setTitleColor(UIColor.appColor(.Red100), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }
    
    private func updateFonts() {
        let fontSize: Int = GTranscribTextParam.FontSize.value
        let font: UIFont = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: GTranscribTextParam.FontWeight.uiFontWieght)
        
        mainTextView.font = font
        placeholderLabel.font = font
        
        mainTextView.textAlignment = NSTextAlignment(rawValue: GTranscribTextParam.TextAlignment.value) ?? .left
        placeholderLabel.textAlignment = NSTextAlignment(rawValue: GTranscribTextParam.TextAlignment.value) ?? .left
    }
    
    private func flipTextView() {
        let flipTransform = CGAffineTransform(scaleX: -1, y: -1)
        let isIdentityTransform = mainTextView.transform == flipTransform
        
        placeholderLabelTopConstraint = placeholderLabelTopConstraint.setRelation(with: isIdentityTransform ? .equal : .greaterThanOrEqual)
        placeholderLabelBottomConstraint = placeholderLabelBottomConstraint.setRelation(with: !isIdentityTransform ? .equal : .greaterThanOrEqual)
        placeholderLabel.transform = isIdentityTransform ? .identity : flipTransform
        
        mainTextView.transform = isIdentityTransform ? .identity : flipTransform
    }
    
    private func presentClearConfirmAlert() {
        presentCustomAlert(
            withMessageText: "Delete this transcript?".localized(),
            dismissButtonText: "Keep".localized(),
            confirmButtonText: "Delete".localized(),
            checkboxViewText: "Don’t ask me again".localized(),
            delegate: self
        )
    }
    
    private func changeTranscribeState(isHapticEnabled: Bool = true, isSaveRecognitionText: Bool = false) {
        let newState = !CTranscribServicesAp.shared.isStartedTranscribe
        CTranscribServicesAp.shared.isStartedTranscribe = newState
        newState ? SAudioKitServicesAp.shared.switchAudioEngine(.recognize) : Void()
        SAudioKitServicesAp.shared.setAudioEngine(newState)
        if isHapticEnabled {
            newState ? TapticEngine.customHaptic.playOn() : TapticEngine.customHaptic.playOff()
        }
        UIApplication.shared.isIdleTimerDisabled = newState
        bottomImageViews[BottomButtonType.transcribe.rawValue].image = newState ? UIImage(named: "micButtonOnIcon") : UIImage(named: "micButtonOffIcon")
        bottomLabels[BottomButtonType.transcribe.rawValue].textColor = UIColor.appColor(.UnactiveButton_1)
        newState && SAudioKitServicesAp.shared.countOfUsingRecognize % 3 == 0 ? KAppConfigServic.shared.settings.presentAppRatingAlert() : Void()
        newState ? SAudioKitServicesAp.shared.increaseCountOfUsing(for: .recognize) : Void()
        
        let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.microphone.rawValue)_\(stringState)"])
        
        if newState {
            placeholderLabel.text = "Start speaking".localized()
            
            CTranscribServicesAp.shared.recognize { [weak self] text in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainTextView.text = text
                    self.textViewDidChange(self.mainTextView)
                }
            } _: { error in
                CTranscribServicesAp.shared.stopRecognition()
            }
        } else {
            placeholderLabel.text = "Tap the Mic button below to get started".localized()
            
            CTranscribServicesAp.shared.stopRecognition(isSaveRecognitionText: isSaveRecognitionText)
            SAudioKitServicesAp.shared.switchAudioEngine(.aid)
        }
    }
    
    private func clearAction() {
        mainTextView.text = ""
        CTranscribServicesAp.shared.transcribeText = ""
        placeholderLabel.text = "Tap the Mic button below to get started".localized()
        placeholderLabel.isHidden = false
        CTranscribServicesAp.shared.cleanDictionary()
        CTranscribServicesAp.shared.isStartedTranscribe ? changeTranscribeState() : Void()
    }
    
    private func saveAction() {
        guard let text = mainTextView.text, !text.isEmpty else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        CTranscribServicesAp.shared.savedTranscripts.append(TranscribeModel(title: text, createdDate: Date().timeIntervalSince1970))
        presentHidingAlert(title: "Transcript successfully saved".localized(), message: "", timeOut: .low)
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
    
    @objc private func shareButtonAction() {
        TapticEngine.impact.feedback(.medium)
        var shareText: String
        if let text = mainTextView.text, !text.isEmpty {
            shareText = text
        } else {
            shareText = "Try this app!".localized() + "🙂"
        }
        shareText += "\n\n✏️ Created by: \(Bundle.main.appName)\n\(CAppConstants.URLs.appStoreUrl)"
        AppsNavManager.shared.presentShareViewController(with: [shareText], and: mainTextView.inputAccessoryView)
        
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.share.rawValue])
    }
    
    @objc private func clearButtonAction() {
        TapticEngine.impact.feedback(.medium)
        clearAction()
        
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardClearText.rawValue])
    }
    
    @objc private func copyAllButtonAction() {
        guard let text = mainTextView.text, !text.isEmpty else {
            return
        }
        TapticEngine.notification.feedback(.success)
        UIPasteboard.general.string = text
        presentHidingAlert(title: "Text successfully copied".localized(), message: "", timeOut: .low)
        
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardCopyAllText.rawValue])
    }
    
    @objc private func saveButtonAction() {
        saveAction()
        
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardSaveText.rawValue])
    }
    
    @objc private func doneButtonAction() {
        TapticEngine.impact.feedback(.medium)
        mainTextView.resignFirstResponder()
        
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardDone.rawValue])
    }
    
    @IBAction private func bottomButtonsAction(_ sender: UIButton) {
        guard let buttonType = BottomButtonType(rawValue: sender.tag) else {
            return
        }
        
        switch buttonType {
        case .clear:
            TapticEngine.impact.feedback(.medium)
            if !notAskConfirmationForDeleteAction {
                presentClearConfirmAlert()
            } else {
                clearAction()
                KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.clearText.rawValue])
            }
        case .save:
            saveAction()
            KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.saveText.rawValue])
        case .transcribe:
            guard CTranscribServicesAp.shared.isStartedTranscribe || TInAppService.shared.isPremium || SAudioKitServicesAp.shared.countOfUsingRecognize < 2 else {
                TapticEngine.impact.feedback(.medium)
                AppsNavManager.shared.presentPaywallViewController(with: .openFromTranscribe)
                return
            }
            
            CTranscribServicesAp.shared.requestRecognitionPermission { [weak self] isAllowed in
                isAllowed ? self?.changeTranscribeState(isSaveRecognitionText: true) : AppsNavManager.shared.presentSReqVoiceRecordApViewController()
            }
        case .flip:
            TapticEngine.impact.feedback(.medium)
            flipTextView()
            KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.flip.rawValue])
        case .setup:
            TapticEngine.impact.feedback(.medium)
            AppsNavManager.shared.presentFTextSetupApViewController(with: .transcribe, with: self)
            KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.textSetup.rawValue])
        }
    }
}

// MARK: - UITextViewDelegate
extension UTranscribApViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        if textView.text.isEmpty == false {
            CTranscribServicesAp.shared.transcribeText = textView.text
        }
        
        let bottomRange = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(bottomRange)
        
        guard !CTranscribServicesAp.shared.isStartedTranscribe else {
            return
        }
        CTranscribServicesAp.shared.cleanDictionary()
        !textView.text.isEmpty ? CTranscribServicesAp.shared.insertToDictionary(new: textView.text) : Void()
    }
}

// MARK: - FTextSetupApViewControllerDelegate
extension UTranscribApViewController: FTextSetupApViewControllerDelegate {
    
    func didUpdateTextParameters() {
        updateFonts()
    }
    
    func didChangeLocale() {
        title = CTranscribServicesAp.shared.localizedSelectedLocale.components(separatedBy: " ").first?.capitalized
    }
}

// MARK: - AlertViewControllerDelegate
extension UTranscribApViewController: AlertViewControllerDelegate {
    
    func onConfirmButtonAction(isCheckboxSelected: Bool) {
        clearAction()
        KAppConfigServic.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.clearText.rawValue])
        notAskConfirmationForDeleteAction = isCheckboxSelected
    }
}
