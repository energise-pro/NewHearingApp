import UIKit

final class TranslateViewController: PMBaseViewController {

    enum BottomButtonType: Int, CaseIterable {
        case clear
        case save
        case transcribe
        case textSetup
        case languageSetup
        
        var image: UIImage? {
            switch self {
            case .clear:
                return Constants.Images.icTrash
            case .save:
                return Constants.Images.icFolder
            case .transcribe:
                return Constants.Images.icTranslateMic
            case .textSetup:
                return Constants.Images.icTextSetup
            case .languageSetup:
                return Constants.Images.icLanguageSetup
            }
        }
        
        var title: String {
            switch self {
            case .clear:
                return "Clear".localized()
            case .save:
                return "Save".localized()
            case .transcribe:
                return "Transcribe".localized()
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
    
    private var keyboardNotification = KeyboardNotification()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TranscribeService.shared.chargeRecognation(on: TranslateService.shared.inputLocale)
        configureUI()
        bottomButtonsAction(microphoneButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TranscribeService.shared.isStartedTranscribe ? changeTranscribeState(isHapticEnabled: false) : Void()
        AudioKitService.shared.switchAudioEngine(.aid)
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        guard motion == .motionShake, TranscribeService.shared.isShakeToClear else {
            return
        }
        presentClearConfirmAlert()
    }
    
    override func didChangeTheme() {
        super.didChangeTheme()
        [navigationItem.leftBarButtonItem, navigationItem.rightBarButtonItem].forEach { $0?.tintColor = ThemeService.shared.activeColor }
    }
    
    // MARK: - Private methods
    private func configureUI() {
        title = TranslateService.shared.localizedInputLanguage.capitalized + " - " + TranslateService.shared.localizedOutputLanguage.capitalized
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonAction))
        [navigationItem.leftBarButtonItem, navigationItem.rightBarButtonItem].forEach { $0?.tintColor = ThemeService.shared.activeColor }
        navigationController?.navigationBar.backgroundColor = .systemBackground
        
        BottomButtonType.allCases.enumerated().forEach { index, buttonType in
            bottomImageViews[index].image = buttonType.image
            bottomLabels[index].text = buttonType.title
            
            bottomImageViews[index].tintColor = UIColor.appColor(.UnactiveButton_1)
            bottomLabels[index].textColor = UIColor.appColor(.UnactiveButton_1)
        }
        
        flipButtonImageView.image = Constants.Images.icFlip
        flipButtonImageView.tintColor = UIColor.appColor(.UnactiveButton_1)
        
        let clearButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(clearButtonAction))
        let copyAllButton = UIBarButtonItem(title: "Copy all".localized(), style: .plain, target: self, action: #selector(copyAllButtonAction))
        let saveButton = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(saveButtonAction))
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneButtonAction))
        
        mainTextViews.forEach {
            $0.addActionBar(with: [clearButton, copyAllButton, saveButton, doneButton])
            $0.tintColor = ThemeService.shared.activeColor
        }
        
        placeholderLabels.forEach {
            $0.text = "Tap the mic to get started ;)".localized()
            $0.textColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.5)
        }
        
        if !TranslateService.shared.translateFromText.isEmpty {
            mainTextViews.last?.text = TranslateService.shared.translateFromText
            textViewDidChange(mainTextViews.last!)
            TranscribeService.shared.insertToDictionary(new: TranslateService.shared.translateFromText)
        }
        
        TranscribeService.shared.availabilityRecognition = { [weak self] available in
            DispatchQueue.main.async {
                self?.placeholderLabels.forEach {
                    $0.text = "Recognition Not Available :(".localized()
                }
            }
        }
        
        keyboardNotification.keyboardWillShow = { [weak self] _ in
            TranscribeService.shared.isStartedTranscribe ? self?.changeTranscribeState(isHapticEnabled: false) : Void()
        }
        
        updateFonts()
    }
    
    private func updateFonts() {
        let fontSize: Int = TranscribeTextParameter.FontSize.value
        let font: UIFont = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: TranscribeTextParameter.FontWeight.uiFontWieght)
        
        mainTextViews.forEach {
            $0.font = font
            $0.textAlignment = NSTextAlignment(rawValue: TranscribeTextParameter.TextAlignment.value) ?? .left
        }
        
        placeholderLabels.forEach {
            $0.font = font
            $0.textAlignment = NSTextAlignment(rawValue: TranscribeTextParameter.TextAlignment.value) ?? .left
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
        let yesAction = UIAlertAction(title: "Yes!".localized(), style: .default) { [weak self] _ in
            self?.clearAction()
            
            AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.clearText.rawValue])
        }
        let noAction = UIAlertAction(title: "No".localized(), style: .default)
        presentAlertPM(title: "Are you sure you want to remove text?".localized(), message: "", actions: [noAction, yesAction])
    }
    
    private func changeTranscribeState(isHapticEnabled: Bool = true, isSaveRecognitionText: Bool = false) {
        let newState = !TranscribeService.shared.isStartedTranscribe
        TranscribeService.shared.isStartedTranscribe = newState
        newState ? AudioKitService.shared.switchAudioEngine(.recognize) : Void()
        AudioKitService.shared.setAudioEngine(newState)
        if isHapticEnabled {
            newState ? TapticEngine.customHaptic.playOn() : TapticEngine.customHaptic.playOff()
        }
        UIApplication.shared.isIdleTimerDisabled = newState
        bottomImageViews[BottomButtonType.transcribe.rawValue].tintColor = newState ? ThemeService.shared.activeColor : UIColor.appColor(.UnactiveButton_1)
        bottomLabels[BottomButtonType.transcribe.rawValue].textColor = UIColor.appColor(.UnactiveButton_1)
        newState && AudioKitService.shared.countOfUsingRecognize % 3 == 0 ? AppConfiguration.shared.settings.presentAppRatingAlert() : Void()
        newState ? AudioKitService.shared.increaseCountOfUsing(for: .translate) : Void()
        
        let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
        AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.microphone.rawValue)_\(stringState)"])
        
        if newState {
            placeholderLabels.forEach {
                $0.text = "Go ahead, I'm listening :)".localized()
            }
            
            TranscribeService.shared.recognize { [weak self] text in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainTextViews.last?.text = text
                    self.textViewDidChange(self.mainTextViews.last!)
                }
            } _: { error in
                TranscribeService.shared.stopRecognition()
            }
        } else {
            placeholderLabels.forEach {
                $0.text = "Tap the mic to get started ;)".localized()
            }
            
            TranscribeService.shared.stopRecognition(isSaveRecognitionText: isSaveRecognitionText)
            AudioKitService.shared.switchAudioEngine(.aid)
        }
    }
    
    private func clearAction() {
        mainTextViews.forEach { $0.text = "" }
        TranslateService.shared.translateFromText = ""
        TranslateService.shared.translateToText = ""
        placeholderLabels.forEach {
            $0.text = "Tap the mic to get started ;)".localized()
            $0.isHidden = false
        }
        TranscribeService.shared.cleanDictionary()
        TranscribeService.shared.isStartedTranscribe ? changeTranscribeState() : Void()
    }
    
    private func saveAction() {
        guard let text = mainTextViews.last?.text, !text.isEmpty else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        TranscribeService.shared.savedTranscripts.append(TranscribeModel(title: text + "\n\n" + (mainTextViews.first?.text ?? ""), createdDate: Date().timeIntervalSince1970))
        presentHidingAlert(title: "Transcript successfully saved".localized(), message: "", timeOut: .low)
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
    
    @objc private func shareButtonAction() {
        TapticEngine.impact.feedback(.medium)
        var shareText: String
        if let text = mainTextViews.last?.text, !text.isEmpty {
            shareText = text + "\n\n" + (mainTextViews.first?.text ?? "")
        } else {
            shareText = "Try this app!".localized() + "🙂"
        }
        shareText += "\n\n✏️ Created by: \(Bundle.main.appName)\n\(Constants.URLs.appStoreUrl)"
        NavigationManager.shared.presentShareViewController(with: [shareText], and: mainTextViews.last?.inputAccessoryView)
        
        AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.share.rawValue])
    }
    
    @objc private func clearButtonAction() {
        TapticEngine.impact.feedback(.medium)
        clearAction()
        
        AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardClearText.rawValue])
    }
    
    @objc private func copyAllButtonAction() {
        guard let text = mainTextViews.last?.text, !text.isEmpty else {
            return
        }
        TapticEngine.notification.feedback(.success)
        UIPasteboard.general.string = text + "\n\n" + (mainTextViews.first?.text ?? "")
        presentHidingAlert(title: "Text successfully copied".localized(), message: "", timeOut: .low)
        
        AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardCopyAllText.rawValue])
    }
    
    @objc private func saveButtonAction() {
        saveAction()
        
        AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardSaveText.rawValue])
    }
    
    @objc private func doneButtonAction() {
        TapticEngine.impact.feedback(.medium)
        mainTextViews.last?.resignFirstResponder()
        
        AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardDone.rawValue])
    }
    
    @IBAction private func bottomButtonsAction(_ sender: UIButton) {
        guard let buttonType = BottomButtonType(rawValue: sender.tag) else {
            return
        }
        
        switch buttonType {
        case .clear:
            TapticEngine.impact.feedback(.medium)
            presentClearConfirmAlert()
        case .save:
            saveAction()
            AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.saveText.rawValue])
        case .transcribe:
            guard TranscribeService.shared.isStartedTranscribe || InAppPurchasesService.shared.isPremium || AudioKitService.shared.countOfTranslate < 2 else {
                TapticEngine.impact.feedback(.medium)
                NavigationManager.shared.presentPaywallViewController(with: .openFromTranscribe)
                return
            }
            
            TranscribeService.shared.requestRecognitionPermission { [weak self] isAllowed in
                isAllowed ? self?.changeTranscribeState(isSaveRecognitionText: true): NavigationManager.shared.presentRequestVoiceRecordingViewController()
            }
        case .textSetup:
            TapticEngine.impact.feedback(.medium)
            NavigationManager.shared.presentTextSetupViewController(with: .translate, with: self)
            AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.textSetup.rawValue])
        case .languageSetup:
            TapticEngine.impact.feedback(.medium)
            NavigationManager.shared.presentLanguangeSetupViewController(with: self)
            AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.languageSetup.rawValue])
        }
    }
    
    @IBAction private func flipButtonAction(_ sender: UIButton) {
        TapticEngine.impact.feedback(.medium)
        flipTextView()
        AppConfiguration.shared.analytics.track(action: .v2TranslateScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.flip.rawValue])
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
extension TranslateViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let index = mainTextViews.firstIndex(where: { $0 == textView }) {
            placeholderLabels[index].isHidden = !textView.text.isEmpty
            
            if textView.text.isEmpty == false {
                if index == 0 {
                    TranslateService.shared.translateToText = textView.text
                } else {
                    TranslateService.shared.translateFromText = textView.text
                }
            }
        }
        
        if mainTextViews.last == textView {
            TranslateService.shared.translate(text: textView.text) { [weak self] translationText in
                guard let lastTextView = self?.mainTextViews.first else {
                    return
                }
                lastTextView.text = translationText
                self?.textViewDidChange(lastTextView)
            }
        }
        
        let bottomRange = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(bottomRange)
        
        guard !TranscribeService.shared.isStartedTranscribe, mainTextViews.last == textView else {
            return
        }
        TranscribeService.shared.cleanDictionary()
        !textView.text.isEmpty ? TranscribeService.shared.insertToDictionary(new: textView.text) : Void()
    }
}

// MARK: - TextSetupViewControllerDelegate
extension TranslateViewController: TextSetupViewControllerDelegate {
    
    func didUpdateTextParameters() {
        updateFonts()
    }
}

// MARK: - LanguageSetupViewControllerDelegate
extension TranslateViewController: LanguageSetupViewControllerDelegate {
    
    func didChangeLocale() {
        title = TranslateService.shared.localizedInputLanguage.capitalized + " - " + TranslateService.shared.localizedOutputLanguage.capitalized
    }
}
