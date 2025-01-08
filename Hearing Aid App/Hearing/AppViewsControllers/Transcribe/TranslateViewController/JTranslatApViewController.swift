import UIKit

protocol JTranslatApViewControllerDelegate: AnyObject {
    func didUpdateTranscript()
}

final class JTranslatApViewController: PMUMainViewController {

    enum BottomButtonType: Int, CaseIterable {
        case clear
        case save
        case transcribe
        case textSetup
        case languageSetup
        
        var image: UIImage? {
            switch self {
            case .clear:
                return CAppConstants.Images.icTrash
            case .save:
                return CAppConstants.Images.icFolder
            case .transcribe:
                return CAppConstants.Images.icTranslateMic
            case .textSetup:
                return CAppConstants.Images.icTextSetup
            case .languageSetup:
                return CAppConstants.Images.icLanguageSetup
            }
        }
        
        var title: String {
            switch self {
            case .clear:
                return "Delete".localized()
            case .save:
                return "Save".localized()
            case .transcribe:
                return ""
            case .textSetup:
                return "Text".localized()
            case .languageSetup:
                return "Language".localized()
            }
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var mainContainerView: UIView!
    @IBOutlet private weak var centerContainerView: UIView!
    
    @IBOutlet private weak var flipButtonImageView: UIImageView!
    
    @IBOutlet private var mainTextViews: [UITextView]!
    
    @IBOutlet private var placeholderLabels: [UILabel]!
    
    @IBOutlet private var bottomImageViews: [UIImageView]!
    @IBOutlet private var bottomLabels: [UILabel]!
    
    @IBOutlet private weak var microphoneButton: UIButton!
    
    @IBOutlet private weak var topPlaceholderLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topPlaceholderLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var centerViewYConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomBackgroundView: UIView!
    
    private weak var delegate: JTranslatApViewControllerDelegate?
    private var keyboardNotification = KeyboardNotification()
    private(set) var notAskConfirmationForDeleteAction: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "notAskConfirmationForDeleteTranslateAction")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "notAskConfirmationForDeleteTranslateAction")
        }
    }
    
    // MARK: - Init
    init(delegate: JTranslatApViewControllerDelegate?) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        CTranscribServicesAp.shared.chargeRecognation(on: BTranslServicesNew.shared.inputLocale)
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
        KAppConfigServic.shared.analytics.track(action: .delete, with: [
            "object" : GAppAnalyticActions.translate.rawValue
        ])
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        [navigationItem.leftBarButtonItem, navigationItem.rightBarButtonItem].forEach { $0?.tintColor = AThemeServicesAp.shared.activeColor }
    }
    
    // MARK: - Private methods
    private func configureUI() {
        overrideUserInterfaceStyle = .light
        
        title = BTranslServicesNew.shared.localizedInputLanguage.capitalized + " - " + BTranslServicesNew.shared.localizedOutputLanguage.capitalized
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appColor(.Purple100)!]
        let shareButtonItem = UIBarButtonItem(image: UIImage(named: "shareButtonIcon"), style: .plain, target: self, action: #selector(shareButtonAction))
        
        let switchButton = UIButton(type: .custom)
        switchButton.setImage(UIImage(named: "arrowRotateIcon"), for: .normal)
        switchButton.addTarget(self, action: #selector(switchButtonAction), for: .touchUpInside)
        switchButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        
        let switchButtonItemView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        switchButtonItemView.bounds = switchButtonItemView.bounds.offsetBy(dx: 12, dy: 1)
        switchButtonItemView.addSubview(switchButton)
        let switchButtonItem = UIBarButtonItem(customView: switchButtonItemView)

        navigationItem.leftBarButtonItems = [shareButtonItem, switchButtonItem]
        navigationController?.navigationBar.barTintColor = UIColor.appColor(.White100)!
        setupRightBarButton()
        
        BottomButtonType.allCases.enumerated().forEach { index, buttonType in
            bottomImageViews[index].image = buttonType.image
            bottomLabels[index].text = buttonType.title
            
            bottomImageViews[index].tintColor = UIColor.appColor(.White100)
            bottomLabels[index].textColor = UIColor.appColor(.White100)
        }
        
        flipButtonImageView.image = CAppConstants.Images.icFlip
        flipButtonImageView.tintColor = UIColor.appColor(.UnactiveButton_1)
        
        let clearButton = UIBarButtonItem(image: UIImage(named: "trashIcon"), style: .plain, target: self, action: #selector(clearButtonAction))
        let copyAllButton = UIBarButtonItem(title: "Copy all".localized(), style: .plain, target: self, action: #selector(copyAllButtonAction))
        let saveButton = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(saveButtonAction))
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneButtonAction))
        
        mainTextViews.forEach {
            $0.addActionBar(with: [clearButton, copyAllButton, saveButton, doneButton])
            $0.tintColor = AThemeServicesAp.shared.activeColor
        }
        
        placeholderLabels.forEach {
            $0.text = "Tap the Mic button below to get started".localized()
            $0.textColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.5)
        }
        
        navigationItem.leftBarButtonItems?.forEach {
            $0.tintColor = UIColor.appColor(.Red100)
        }
        
        if !BTranslServicesNew.shared.translateFromText.isEmpty {
            mainTextViews.last?.text = BTranslServicesNew.shared.translateFromText
            textViewDidChange(mainTextViews.last!)
            CTranscribServicesAp.shared.insertToDictionary(new: BTranslServicesNew.shared.translateFromText)
        }
        
        CTranscribServicesAp.shared.availabilityRecognition = { [weak self] available in
            DispatchQueue.main.async {
                self?.placeholderLabels.forEach {
                    $0.text = "Recognition not available".localized()
                }
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
        
        mainTextViews.forEach {
            $0.font = font
            $0.textAlignment = NSTextAlignment(rawValue: GTranscribTextParam.TextAlignment.value) ?? .left
        }
        
        placeholderLabels.forEach {
            $0.font = font
            $0.textAlignment = NSTextAlignment(rawValue: GTranscribTextParam.TextAlignment.value) ?? .left
        }
    }
    
    private func flipTextView() {
        let flipTransform = CGAffineTransform(scaleX: -1, y: -1)
        let isIdentityTransform = mainTextViews.first?.transform == flipTransform
        
        topPlaceholderLabelTopConstraint = topPlaceholderLabelTopConstraint.setRelation(with: isIdentityTransform ? .equal : .greaterThanOrEqual)
        topPlaceholderLabelBottomConstraint = topPlaceholderLabelBottomConstraint.setRelation(with: !isIdentityTransform ? .equal : .greaterThanOrEqual)
        placeholderLabels.first?.transform = isIdentityTransform ? .identity : flipTransform
        
        mainTextViews.first?.transform = isIdentityTransform ? .identity : flipTransform
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
        newState ? SAudioKitServicesAp.shared.increaseCountOfUsing(for: .translate) : Void()
        
        let actionState = newState ? GAppAnalyticActions.translateActivated : GAppAnalyticActions.translateDeactivated
        KAppConfigServic.shared.analytics.track(action: actionState, with: [
            "language_user" : BTranslServicesNew.shared.localizedInputLanguage.capitalized,
            "language_translate" : BTranslServicesNew.shared.localizedOutputLanguage.capitalized,
            "offline_translation_status" : CTranscribServicesAp.shared.isOfflineTranslate,
            "font_size" : Float(GTranscribTextParam.FontSize.value),
            "font_weight" : GTranscribTextParam.FontWeight.value == 0 ? "medium" : (GTranscribTextParam.FontWeight.value == 1 ? "semibold" : "bold"),
            "text_alignment" : GTranscribTextParam.TextAlignment.stringTextAlignment,
            "shake_delete_options" : CTranscribServicesAp.shared.isShakeToClear
        ])
        
        if newState {
            placeholderLabels.forEach {
                $0.text = "Start speaking".localized()
            }
            
            CTranscribServicesAp.shared.recognize { [weak self] text in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainTextViews.last?.text = text
                    self.textViewDidChange(self.mainTextViews.last!)
                }
            } _: { error in
                CTranscribServicesAp.shared.stopRecognition()
            }
        } else {
            placeholderLabels.forEach {
                $0.text = "Tap the Mic button below to get started".localized()
            }
            
            CTranscribServicesAp.shared.stopRecognition(isSaveRecognitionText: isSaveRecognitionText)
            SAudioKitServicesAp.shared.switchAudioEngine(.aid)
        }
    }
    
    private func clearAction() {
        mainTextViews.forEach { $0.text = "" }
        BTranslServicesNew.shared.translateFromText = ""
        BTranslServicesNew.shared.translateToText = ""
        placeholderLabels.forEach {
            $0.text = "Tap the Mic button below to get started".localized()
            $0.isHidden = false
        }
        CTranscribServicesAp.shared.cleanDictionary()
        CTranscribServicesAp.shared.isStartedTranscribe ? changeTranscribeState() : Void()
    }
    
    private func saveAction() {
        guard let text = mainTextViews.last?.text, !text.isEmpty else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        if !CTranscribServicesAp.shared.isSavedFirstTranscripts {
            CTranscribServicesAp.shared.isSavedFirstTranscripts = true
            CTranscribServicesAp.shared.isShowGetStartedView = false
        }
        CTranscribServicesAp.shared.savedTranscripts.append(TranscribeModel(title: text + "\n\n" + (mainTextViews.first?.text ?? ""), createdDate: Date().timeIntervalSince1970))
        presentCustomHidingAlert(message: "Transcript successfully saved!".localized())
        delegate?.didUpdateTranscript()
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
//        KAppConfigServic.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
    
    @objc private func shareButtonAction() {
        TapticEngine.impact.feedback(.medium)
        var shareText: String
        if let text = mainTextViews.last?.text, !text.isEmpty {
            shareText = text + "\n\n" + (mainTextViews.first?.text ?? "")
        } else {
            shareText = "Try this app!".localized() + "🙂"
        }
        shareText += "\n\n✏️ Created by: \(Bundle.main.appName)\n\(CAppConstants.URLs.appStoreUrl)"
        AppsNavManager.shared.presentShareViewController(with: [shareText], and: mainTextViews.last?.inputAccessoryView)
        
        KAppConfigServic.shared.analytics.track(action: .share, with: [
            "object" : GAppAnalyticActions.translate.rawValue
        ])
    }
    
    @objc private func switchButtonAction() {
        let inputLanguage = BTranslServicesNew.shared.inputLanguage
        let outputLanguage = BTranslServicesNew.shared.outputLanguage
        
        let firstText = mainTextViews.first?.text
        let lastText = mainTextViews.last?.text
        
        BTranslServicesNew.shared.inputLanguage = outputLanguage
        BTranslServicesNew.shared.outputLanguage = inputLanguage
        
        mainTextViews.first?.text = lastText
        mainTextViews.last?.text = firstText
        
        title = BTranslServicesNew.shared.localizedInputLanguage.capitalized + " - " + BTranslServicesNew.shared.localizedOutputLanguage.capitalized
    }
    
    @objc private func clearButtonAction() {
        TapticEngine.impact.feedback(.medium)
        clearAction()
        
        KAppConfigServic.shared.analytics.track(action: .delete, with: [
            "object" : GAppAnalyticActions.translate.rawValue
        ])
    }
    
    @objc private func copyAllButtonAction() {
        guard let text = mainTextViews.last?.text, !text.isEmpty else {
            return
        }
        TapticEngine.notification.feedback(.success)
        UIPasteboard.general.string = text + "\n\n" + (mainTextViews.first?.text ?? "")
        presentHidingAlert(title: "Text successfully copied".localized(), message: "", timeOut: .low)
        
//        KAppConfigServic.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardCopyAllText.rawValue])
    }
    
    @objc private func saveButtonAction() {
        saveAction()
        
        KAppConfigServic.shared.analytics.track(action: .saved, with: [
            "object" : GAppAnalyticActions.translate.rawValue
        ])
    }
    
    @objc private func doneButtonAction() {
        TapticEngine.impact.feedback(.medium)
        mainTextViews.last?.resignFirstResponder()
        
//        KAppConfigServic.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardDone.rawValue])
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
                KAppConfigServic.shared.analytics.track(action: .delete, with: [
                    "object" : GAppAnalyticActions.translate.rawValue
                ])
            }
        case .save:
            saveAction()
            KAppConfigServic.shared.analytics.track(action: .saved, with: [
                "object" : GAppAnalyticActions.translate.rawValue
            ])
//            KAppConfigServic.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.saveText.rawValue])
        case .transcribe:
            guard CTranscribServicesAp.shared.isStartedTranscribe || TInAppService.shared.isPremium || SAudioKitServicesAp.shared.countOfTranslate < 2 else {
                TapticEngine.impact.feedback(.medium)
                AppsNavManager.shared.presentPaywallViewController(with: .sourceTranslateBtn)
                return
            }
            
            CTranscribServicesAp.shared.requestRecognitionPermission { [weak self] isAllowed in
                isAllowed ? self?.changeTranscribeState(isSaveRecognitionText: true): AppsNavManager.shared.presentSReqVoiceRecordApViewController(with: .translate)
            }
        case .textSetup:
            TapticEngine.impact.feedback(.medium)
            AppsNavManager.shared.presentFTextSetupApViewController(with: .translate, with: self)
//            KAppConfigServic.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.textSetup.rawValue])
        case .languageSetup:
            TapticEngine.impact.feedback(.medium)
            AppsNavManager.shared.presentLanguangeSetupViewController(with: self)
//            KAppConfigServic.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.languageSetup.rawValue])
        }
    }
    
    @IBAction private func flipButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        flipTextView()
//        KAppConfigServic.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.flip.rawValue])
    }
    
    @IBAction private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: centerContainerView)
        guard abs(centerViewYConstraint.constant + location.y) * 2.0 < (mainContainerView.bounds.height * 0.65) else {
            return
        }
        centerViewYConstraint.constant += location.y
        TapticEngine.selection.feedback()
    }
}

// MARK: - UITextViewDelegate
extension JTranslatApViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let index = mainTextViews.firstIndex(where: { $0 == textView }) {
            placeholderLabels[index].isHidden = !textView.text.isEmpty
            
            if textView.text.isEmpty == false {
                if index == 0 {
                    BTranslServicesNew.shared.translateToText = textView.text
                } else {
                    BTranslServicesNew.shared.translateFromText = textView.text
                }
            }
        }
        
        if mainTextViews.last == textView {
            BTranslServicesNew.shared.translate(text: textView.text) { [weak self] translationText in
                guard let lastTextView = self?.mainTextViews.first else {
                    return
                }
                lastTextView.text = translationText
                self?.textViewDidChange(lastTextView)
            }
        }
        
        let bottomRange = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(bottomRange)
        
        guard !CTranscribServicesAp.shared.isStartedTranscribe, mainTextViews.last == textView else {
            return
        }
        CTranscribServicesAp.shared.cleanDictionary()
        !textView.text.isEmpty ? CTranscribServicesAp.shared.insertToDictionary(new: textView.text) : Void()
    }
}

// MARK: - FTextSetupApViewControllerDelegate
extension JTranslatApViewController: FTextSetupApViewControllerDelegate {
    
    func didUpdateTextParameters() {
        updateFonts()
    }
}

// MARK: - GLangSetupApViewControllerDelegate
extension JTranslatApViewController: GLangSetupApViewControllerDelegate {
    
    func didChangeLocale() {
        title = BTranslServicesNew.shared.localizedInputLanguage.capitalized + " - " + BTranslServicesNew.shared.localizedOutputLanguage.capitalized
    }
}

// MARK: - AlertViewControllerDelegate
extension JTranslatApViewController: AlertViewControllerDelegate {
    
    func onConfirmButtonAction(isCheckboxSelected: Bool) {
        clearAction()
        notAskConfirmationForDeleteAction = isCheckboxSelected
        KAppConfigServic.shared.analytics.track(action: .delete, with: [
            "object" : GAppAnalyticActions.translate.rawValue,
            "dont_ask_checkbox_status" : isCheckboxSelected
        ])
    }
}
