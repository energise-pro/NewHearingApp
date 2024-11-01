import UIKit

final class TranscribeViewController: PMBaseViewController {
    
    enum BottomButtonType: Int, CaseIterable {
        case clear
        case save
        case transcribe
        case flip
        case setup
        
        var image: UIImage? {
            switch self {
            case .clear:
                return Constants.Images.icTrash
            case .save:
                return Constants.Images.icFolder
            case .transcribe:
                return UIImage.init(systemName: "mic.circle")
            case .flip:
                return Constants.Images.icFlip
            case .setup:
                return Constants.Images.icTextSetup
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
    
    private var keyboardNotification = KeyboardNotification()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TranscribeService.shared.chargeRecognation()
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
        title = TranscribeService.shared.localizedSelectedLocale.components(separatedBy: " ").first?.capitalized
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonAction))
        [navigationItem.leftBarButtonItem, navigationItem.rightBarButtonItem].forEach { $0?.tintColor = ThemeService.shared.activeColor }
        
        BottomButtonType.allCases.enumerated().forEach { index, buttonType in
            bottomImageViews[index].image = buttonType.image
            bottomLabels[index].text = buttonType.title
            
            bottomImageViews[index].tintColor = UIColor.appColor(.UnactiveButton_1)
            bottomLabels[index].textColor = UIColor.appColor(.UnactiveButton_1)
        }
        
        let clearButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(clearButtonAction))
        let copyAllButton = UIBarButtonItem(title: "Copy all".localized(), style: .plain, target: self, action: #selector(copyAllButtonAction))
        let saveButton = UIBarButtonItem(title: "Save".localized(), style: .plain, target: self, action: #selector(saveButtonAction))
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: self, action: #selector(doneButtonAction))
        mainTextView.addActionBar(with: [clearButton, copyAllButton, saveButton, doneButton])
        
        placeholderLabel.text = "Tap the mic to get started ;)".localized()
        placeholderLabel.textColor = UIColor.appColor(.UnactiveButton_1)?.withAlphaComponent(0.5)
        
        mainTextView.tintColor = ThemeService.shared.activeColor
        
        if !TranscribeService.shared.transcribeText.isEmpty {
            mainTextView.text = TranscribeService.shared.transcribeText
            textViewDidChange(mainTextView)
            TranscribeService.shared.insertToDictionary(new: TranscribeService.shared.transcribeText)
        }
        
        TranscribeService.shared.availabilityRecognition = { [weak self] available in
            DispatchQueue.main.async {
                self?.placeholderLabel.text = "Recognition Not Available :(".localized()
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
        
        mainTextView.font = font
        placeholderLabel.font = font
        
        mainTextView.textAlignment = NSTextAlignment(rawValue: TranscribeTextParameter.TextAlignment.value) ?? .left
        placeholderLabel.textAlignment = NSTextAlignment(rawValue: TranscribeTextParameter.TextAlignment.value) ?? .left
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
        let yesAction = UIAlertAction(title: "Yes!".localized(), style: .default) { [weak self] _ in
            self?.clearAction()
            
            AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.clearText.rawValue])
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
        newState ? AudioKitService.shared.increaseCountOfUsing(for: .recognize) : Void()
        
        let stringState = newState ? GAppAnalyticActions.enable.rawValue : GAppAnalyticActions.disable.rawValue
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: "\(GAppAnalyticActions.microphone.rawValue)_\(stringState)"])
        
        if newState {
            placeholderLabel.text = "Go ahead, I'm listening :)".localized()
            
            TranscribeService.shared.recognize { [weak self] text in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainTextView.text = text
                    self.textViewDidChange(self.mainTextView)
                }
            } _: { error in
                TranscribeService.shared.stopRecognition()
            }
        } else {
            placeholderLabel.text = "Tap the mic to get started ;)".localized()
            
            TranscribeService.shared.stopRecognition(isSaveRecognitionText: isSaveRecognitionText)
            AudioKitService.shared.switchAudioEngine(.aid)
        }
    }
    
    private func clearAction() {
        mainTextView.text = ""
        TranscribeService.shared.transcribeText = ""
        placeholderLabel.text = "Tap the mic to get started ;)".localized()
        placeholderLabel.isHidden = false
        TranscribeService.shared.cleanDictionary()
        TranscribeService.shared.isStartedTranscribe ? changeTranscribeState() : Void()
    }
    
    private func saveAction() {
        guard let text = mainTextView.text, !text.isEmpty else {
            return
        }
        TapticEngine.impact.feedback(.medium)
        TranscribeService.shared.savedTranscripts.append(TranscribeModel(title: text, createdDate: Date().timeIntervalSince1970))
        presentHidingAlert(title: "Transcript successfully saved".localized(), message: "", timeOut: .low)
    }
    
    // MARK: - Actions
    @objc private func closeButtonAction() {
        dismiss(animated: true)
        
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.close.rawValue])
    }
    
    @objc private func shareButtonAction() {
        TapticEngine.impact.feedback(.medium)
        var shareText: String
        if let text = mainTextView.text, !text.isEmpty {
            shareText = text
        } else {
            shareText = "Try this app!".localized() + "🙂"
        }
        shareText += "\n\n✏️ Created by: \(Bundle.main.appName)\n\(Constants.URLs.appStoreUrl)"
        NavigationManager.shared.presentShareViewController(with: [shareText], and: mainTextView.inputAccessoryView)
        
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.share.rawValue])
    }
    
    @objc private func clearButtonAction() {
        TapticEngine.impact.feedback(.medium)
        clearAction()
        
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardClearText.rawValue])
    }
    
    @objc private func copyAllButtonAction() {
        guard let text = mainTextView.text, !text.isEmpty else {
            return
        }
        TapticEngine.notification.feedback(.success)
        UIPasteboard.general.string = text
        presentHidingAlert(title: "Text successfully copied".localized(), message: "", timeOut: .low)
        
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardCopyAllText.rawValue])
    }
    
    @objc private func saveButtonAction() {
        saveAction()
        
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardSaveText.rawValue])
    }
    
    @objc private func doneButtonAction() {
        TapticEngine.impact.feedback(.medium)
        mainTextView.resignFirstResponder()
        
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.keyboardDone.rawValue])
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
            AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.saveText.rawValue])
        case .transcribe:
            guard TranscribeService.shared.isStartedTranscribe || InAppPurchasesService.shared.isPremium || AudioKitService.shared.countOfUsingRecognize < 2 else {
                TapticEngine.impact.feedback(.medium)
                NavigationManager.shared.presentPaywallViewController(with: .openFromTranscribe)
                return
            }
            
            TranscribeService.shared.requestRecognitionPermission { [weak self] isAllowed in
                isAllowed ? self?.changeTranscribeState(isSaveRecognitionText: true) : NavigationManager.shared.presentRequestVoiceRecordingViewController()
            }
        case .flip:
            TapticEngine.impact.feedback(.medium)
            flipTextView()
            AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.flip.rawValue])
        case .setup:
            TapticEngine.impact.feedback(.medium)
            NavigationManager.shared.presentTextSetupViewController(with: .transcribe, with: self)
            AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [GAppAnalyticActions.action.rawValue: GAppAnalyticActions.textSetup.rawValue])
        }
    }
}

// MARK: - UITextViewDelegate
extension TranscribeViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        if textView.text.isEmpty == false {
            TranscribeService.shared.transcribeText = textView.text
        }
        
        let bottomRange = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(bottomRange)
        
        guard !TranscribeService.shared.isStartedTranscribe else {
            return
        }
        TranscribeService.shared.cleanDictionary()
        !textView.text.isEmpty ? TranscribeService.shared.insertToDictionary(new: textView.text) : Void()
    }
}

// MARK: - TextSetupViewControllerDelegate
extension TranscribeViewController: TextSetupViewControllerDelegate {
    
    func didUpdateTextParameters() {
        updateFonts()
    }
    
    func didChangeLocale() {
        title = TranscribeService.shared.localizedSelectedLocale.components(separatedBy: " ").first?.capitalized
    }
}
