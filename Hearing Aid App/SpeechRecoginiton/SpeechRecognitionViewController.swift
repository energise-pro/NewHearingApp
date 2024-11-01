import UIKit

final class SpeechRecognitionViewController: BaseViewController, OrientationalProtocol {

    @IBOutlet weak var textView: TextView!

    @IBOutlet weak var menuView: SpeechRecognitionMenuView!

    @IBOutlet weak var topMenuStackView: SpeechRecognitionTopMenuView!



    private let speech = SpeechRecognition()

    private let keyboardNotification = KeyboardNotification()

    //translate mode
    @IBOutlet weak var hideTextViewButton: ButtonView!

    @IBOutlet weak var translateToButton: ButtonView!

    @IBOutlet weak var flipTranslationButton: ButtonView!

    @IBOutlet weak var translationControlsView: UIStackView!

    @IBOutlet weak var translationTextView: TextView!

    private lazy var translator = MLTranslator()


    //Amplitude Indicator
    @IBOutlet weak var amplitudeView: UIStackView!
    @IBOutlet weak var amplitudeIndicatorView: UIView!
    private let amplitudeVC = AnalliticAmplViewController()

    private var fullScreenViewController: TextViewFullScreenViewController?

    private var isLandscape: Bool = false

    private var isTranslateMode: Bool = false {
        didSet {
            translationTextView.isHidden = !isTranslateMode
            translationControlsView.isHidden = !isTranslateMode

            if isTranslateMode {
                translateText()
            }

            translateToButton.isSelected = true
            hideTextViewButton.isSelected = true
            flipTranslationButton.isSelected = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioKitService.shared.initializeAudioKit()
        isTranslateMode = SpeechRecognitionSettings.TranslateMode.value as? Bool ?? false
        setupTextView()
        setupAmplitudeIndicator()
        keyboardNotification.keyboardWillShow = { [weak self] _ in
            self?.topMenuStackView.alpha = 0
            self?.topMenuStackView.isHidden = true
        }

        keyboardNotification.keyboardWillHide = { [weak self] _ in
            self?.topMenuStackView.alpha = 1
            self?.topMenuStackView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSupportedOrientations([.portrait, .landscape])
        AudioKitService.shared.switchAudioEngine(.recognize)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isLandscape = false
        setSupportedOrientations(.portrait)
        setOrientation(.portrait)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isLandscape = UIDevice.current.orientation.isLandscape
    }

    private func setupAmplitudeIndicator() {
        let isOn = false //SpeechRecognitionSettings.AmplitudeIndicator.value as! Bool
        amplitudeView.isHidden = !isOn
        addChildController(amplitudeVC, inView: amplitudeIndicatorView)
        updateAmplitudeFrame()
        amplitudeVC.isHorizontal = true
    }

    private func setupTextView() {
        textView.delegate = self
        textView.didSetTextCompletion = { [weak self] text in
            if self?.isTranslateMode == true {
                self?.translateText()
            }
        }

        resetTextView()
        speech.availabilityDidChangeCompletion = { [weak self] available in
            if available {
                self?.resetTextView()
            } else {
                self?.textView.text = "Recognition Not Available :(".localized()
            }
        }
    }

    private func resetTextView() {
        textView.text = "Tap the mic to get started ;)".localized()
        fullText = nil
        deletedText = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SpeechRecognition.requestAuthorization()
        updateAmplitudeFrame()
    }

    private func updateAmplitudeFrame() {
        amplitudeVC.view.frame = amplitudeIndicatorView.bounds
        amplitudeVC.updateFrame()
    }

    @IBAction func settingsAction(sender: UIButton) {
        let vc: SpeechRecognitionSettingsViewController = SpeechRecognitionSettingsViewController.instantiate()
        vc.delegate = self
        presentAsPopover(vc: vc, sourceView: sender, height: 350)
        
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.settings.rawValue])
    }

    @IBAction func shareAction(sender: UIButton) {
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.share.rawValue])
        var shareText = textView.text ?? "Try this app!🙂"
        shareText += "\n\n✏️ Created by: \(Bundle.main.appName)\n\(Constants.URLs.appStoreUrl)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .addToReadingList, .openInIBooks, .markupAsPDF]
        activityVC.popoverPresentationController?.sourceView = sender
        present(activityVC, animated: true)
    }

    @IBAction func changeLanguageAction(sender: UIButton) {
        let localeSelection = SpeechRecognitionLocaleSelectionViewController()
        localeSelection.selectionDelegate = self
        presentAsPopover(vc: localeSelection, sourceView: sender)
        
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.changeLanguage.rawValue])
    }

    @IBAction func hideLeftTextViewAction(sender: UIButton) {
        textView.isHidden = !textView.isHidden
        hideTextViewButton.isSelected = !textView.isHidden
    }

    @IBAction func translateToLanguageAction(sender: UIButton) {
        let localeSelection = TranslateToLanguageSelectionController()
        localeSelection.languages = translator.allLanguages
        localeSelection.selectionDelegate = self
        presentAsPopover(vc: localeSelection, sourceView: sender)
    }

    @IBAction func flipTranslationAction(sender: UIButton) {
        translator.flipTranslate = !translator.flipTranslate
    }

    private var deletedText: String?
    private var fullText: String?
    @IBAction func clearTextAction(sender: UIButton?) {
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.clearText.rawValue])
        UIView.transition(with: textView, duration: 0.4,
                          options: [.curveEaseInOut, .transitionCurlUp], animations: {
                            self.deletedText = self.fullText
                            self.textView.text = ""
                            self.fullScreenViewController?.text = ""
                          }, completion: nil)
    }

    @IBAction func rotate(sender: UIButton) {
        isLandscape = !isLandscape
        
        if isLandscape {
            setOrientation(.landscapeRight)
        } else {
            setOrientation(.portrait)
        }
        
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.rotate.rawValue])
    }

    @IBAction func speechRecognitionAction(sender: UIButton) {
        if !InAppPurchasesService.shared.isPremium {
            NavigationManager.shared.presentPaywallViewController(with: .openFromTranscribe)
            return
        }
        
        SpeechRecognition.requestAuthorization {[weak self] isAuthorization in
            guard let self = self else { return }
            if !isAuthorization {
                NavigationManager.shared.presentRequestVoiceRecordingViewController()
                return
            } else {
                self.speech.stopRecognition()
                self.fullText = nil
                self.deletedText = nil

                let readyText = "Go ahead, I'm listening :)".localized()
                
                if !self.menuView.isRecognitionButtonSelected {
                    AudioKitService.shared.setAudioEngine(true)
                    
                    AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.microphone.rawValue)_\(AnalyticsAction.enable.rawValue)"])
                    
                    UIApplication.shared.isIdleTimerDisabled = true
                    TapticEngine.customHaptic.playOn()
                    AudioKitService.shared.countOfUsingRecognize % 3 == 0 ? AppConfiguration.shared.settings.presentAppRatingAlert() : Void()

                    self.textView.text = readyText
                    self.speech.startRecognition(textHandler: {[weak self] text, _, _ in

                        self?.fullText = text

                        if let deletedText = self?.deletedText {
                            let filteredText = text.replacingOccurrences(of: deletedText, with: "")
                            self?.fullScreenViewController?.text = filteredText
                            self?.textView.text = filteredText
                        } else {
                            self?.fullScreenViewController?.text = text
                            self?.textView.text = text
                        }

                    }, errorHandler: {[weak self] error in
                        self?.menuView.isRecognitionButtonSelected = false
                    })
                } else {
                    AudioKitService.shared.setAudioEngine(false)
                    
                    AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: "\(AnalyticsAction.microphone.rawValue)_\(AnalyticsAction.disable.rawValue)"])
                    
                    UIApplication.shared.isIdleTimerDisabled = false
                    self.speech.stopRecognition()
                    TapticEngine.customHaptic.playOff()
                }

                self.menuView.isRecognitionButtonSelected = !self.menuView.isRecognitionButtonSelected
                self.speech.isRecognitionButtonSelected = self.menuView.isRecognitionButtonSelected
            }
        }
    }

    @IBAction func fullScreenAction(sender:UIButton) {
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.fullScreen.rawValue])
        let vc: TextViewFullScreenViewController = TextViewFullScreenViewController.instantiate()
        vc.delegate = self
        vc.text = textView.text
        vc.transform = textView.transform
        vc.modalPresentationCapturesStatusBarAppearance = true
        fullScreenViewController = vc
        present(vc, animated: true, completion: nil)
    }

    @IBAction func flipAction(sender: UIButton) {
        AppConfiguration.shared.analytics.track(action: .v2TranscribeScreen, with: [AnalyticsAction.action.rawValue: AnalyticsAction.flip.rawValue])

        UIView.animate(withDuration: 0.35) {
            let flipTransform = CGAffineTransform(scaleX: -1, y: -1)
            if self.textView.transform == flipTransform {
                self.textView.transform = .identity
                return
            }
            self.textView.transform = flipTransform
        }
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        let isShakeToClearEnabled = SpeechRecognitionSettings.ShakeToClearText.value as? Bool ?? false
        if motion == .motionShake && isShakeToClearEnabled {
            clearTextAction(sender: nil)
        }
    }
}

extension SpeechRecognitionViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        speech.stopRecognition()
    }
}

extension SpeechRecognitionViewController: SpeechRecognitionLocaleSelectionDelegate, SpeechRecognitionSettingsDelegate, TranslateToLanguageSelectionControllerDelegate {

    func didChangeTextAlignment(_ alignment: NSTextAlignment) {
        textView.textAlignment = alignment
        translationTextView.textAlignment = alignment
    }

    func didChangeFontSize(_ size: Float) {
        textView.updateFontSize(size)
        translationTextView.updateFontSize(size)
    }

    func didChangeFontWeight(_ weight: Int) {
        textView.updateFontWeight(weight)
        translationTextView.updateFontWeight(weight)
    }

    func didToggleSetting(_ setting: SpeechRecognitionSettings,
                          _ value: Bool) {
        switch setting {
        case .TranslateMode:
            isTranslateMode = value
//        case .AmplitudeIndicator:
//            amplitudeView.isHidden = !value
        default:
            break
        }
    }

    func didSelectLocale(_ locale: Locale) {
        speech.setLocale(locale)
        topMenuStackView.updateLanguageButtonTitle()
    }

    func didSelect(language: TranslationLanguage) {
        if MLTranslator.isLanguageDownloaded(language) == true {
            MLTranslator.outputLanguage = language
            translateText()
        } else {
            presentAlert(controller: self, title: "Download?", message: "This language model is not downloaded. Would you like to download it?", leftActionTitle: "No", rightActionTitle: "Yes", leftActionStyle: .cancel, rightActionStyle: .default) {
            } rightActionCompletion: { [weak self] in
                self?.download(language)
            }
        }
    }

    private func download(_ language: TranslationLanguage) {
        ActivityIndicatorView.showActivity(topView: translationTextView, text: "")
        let loca = MLTranslator.localizedString(forLanguage: language) ?? language.rawValue
        translationTextView.text = "Downloading \(loca) ..."
        translator.downloadModel(language: language,
                                  completion: { [weak self] _ in
                                    ActivityIndicatorView.hideActivity()
                                    self?.translateText()
                                  })
    }

    private func translateText() {
        translateToButton.title?.text = MLTranslator.localizedStringForSelectedLanguage()

        translator.translate(text: textView.text) { [weak self] translation in
            self?.translationTextView.text = translation
        }
    }
}

extension SpeechRecognitionViewController: TextViewFullScreenViewControllerDelegate {

    func didExitFullScreen() {
        fullScreenViewController = nil
    }
}

final class TextView: SpringTextView {

    private var fontWeight: Int = SpeechRecognitionSettings.FontWeight.value as! Int
    private var fontSize: Float = SpeechRecognitionSettings.FontSize.value as! Float

    override var text: String! {
        get { return super.text }
        set {
            UIView.transition(with: self, duration: 0.15,
                              options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                super.text = newValue
                self.scrollToBottom()
            }, completion: nil)
            didSetTextCompletion?(text)
        }
    }


    var didSetTextCompletion: ((String) -> Void)?

    func scrollToBottom() {
        if contentSize.height > bounds.height {
            let point = CGPoint(x: 0.0, y: (contentSize.height - bounds.height))
            setContentOffset(point, animated: true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateFontSize(fontSize)
        let alignment = NSTextAlignment(rawValue: SpeechRecognitionSettings.TextAlignment.value as! Int) ?? .left
        textAlignment = alignment
        textColor = Theme.buttonInactiveColor
    }

    func updateFontSize(_ size: Float) {
        fontSize = size
        if fontWeight == 0 {
            font = UIFont.systemFont(ofSize: CGFloat(size), weight: .regular)
        } else if fontWeight == 1 {
            font = UIFont.systemFont(ofSize: CGFloat(size), weight: .medium)
        } else {
            font = UIFont.systemFont(ofSize: CGFloat(size), weight: .bold)
        }
    }

    func updateFontWeight(_ weight: Int) {
        fontWeight = weight
        updateFontSize(fontSize)
    }
}

final class SpeechRecognitionMenuView: UIStackView {
    @IBOutlet weak var clearButton: ButtonView!
    @IBOutlet weak var rotateButton: ButtonView!
    @IBOutlet weak var recognitionButton: ButtonView!
    @IBOutlet weak var fullScreenButton: ButtonView!
    @IBOutlet weak var flipButton: ButtonView!


    override func awakeFromNib() {
        super.awakeFromNib()
        clearButton.isSelected = true
        rotateButton.isSelected = true
        fullScreenButton.isSelected = true
        flipButton.isSelected = true
        recognitionButton.isSelected = true
        isRecognitionButtonSelected = false
        recognitionButton.button.impactStyle = .heavy

        clearButton.title?.text = "Clear".localized()
        rotateButton.title?.text = "Rotate".localized()
        flipButton.title?.text = "Flip".localized()
        fullScreenButton.title?.text = "Full Screen".localized()
    }

    var isRecognitionButtonSelected: Bool = false {
        didSet {
            recognitionButton.isSelected = isRecognitionButtonSelected
            if isRecognitionButtonSelected {
                recognitionButton.animate(name:"flash", repeatCount:.infinity)
            } else {
                recognitionButton.layer.removeAllAnimations()
            }
        }
    }
}

final class SpeechRecognitionTopMenuView: UIStackView {

    @IBOutlet weak var shareButton: ButtonView!
    @IBOutlet weak var languageButton: ButtonView!
    @IBOutlet weak var settingsButton: ButtonView!

    override func awakeFromNib() {
        super.awakeFromNib()
        shareButton.isSelected = true
        languageButton.isSelected = true
        settingsButton.isSelected = true
        languageButton.isSelected = true
        updateLanguageButtonTitle()
        shareButton.title?.text = "Share Text".localized()
        settingsButton.title?.text = "Settings".localized()
    }

    func updateLanguageButtonTitle() {
        let language = SpeechRecognition.localizedSelectedLanguage()
        languageButton.title?.text = language
    }
}
