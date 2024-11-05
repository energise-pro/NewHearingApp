import UIKit
import Speech
import AudioKit

public typealias SpeechRecognitionCompletion = (String, Bool, Any?) -> Void
public typealias SpeechErrorHandler = (Error?) -> Void

public class SpeechRecognition: NSObject, SFSpeechRecognizerDelegate {
    private static let AUDIO_BUFFER_SIZE: UInt32 = 1_024
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechTask: SFSpeechRecognitionTask?

    var availabilityDidChangeCompletion: ((Bool) -> Void)? = nil

    var isRecognitionButtonSelected = false

    override init() {
        super.init()
        let locale = Locale(identifier: currentSelectedLocale)
        setLocale(locale)
    }

    public func setLocale(_ locale: Locale) {
        stopRecognition()
        self.recognizer = SFSpeechRecognizer(locale: locale)
        self.recognizer?.delegate = self
        self.recognizer?.defaultTaskHint = .dictation
    }

    /// Helper to get a list of supported locales
    public static func supportedLocales() -> [Locale] {
        return Array(SFSpeechRecognizer.supportedLocales()).sorted(by: { $0.identifier < $1.identifier})
    }

    public static func localizedSelectedLanguage() -> String {
        guard let locale = supportedLocales().filter({ $0.identifier == currentSelectedLocale }).first else {
            return "Language"
        }
        return locale.localizedString(forIdentifier: locale.identifier) ?? "Language"
    }

    /// Helper to request authorization for voice search
    public static func requestAuthorization(_ statusHandler: ((Bool) -> Void)? = nil ) {

        if SFSpeechRecognizer.authorizationStatus() == .authorized {
            statusHandler?(true)
            return
        }

        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    statusHandler?(true)
                case .denied:
                    statusHandler?(false)
                case .restricted:
                    statusHandler?(false)
                case .notDetermined:
                    statusHandler?(false)
                    presentError(customDescription:"Speech recognition not yet authorized")
                @unknown default:
                    statusHandler?(false)
                }
            }
        }
    }

    /// The method is going to give an infinite stream of speech-to-text until `stopRecording` is called or an error is encounter
    public func startRecognition(textHandler: @escaping SpeechRecognitionCompletion, errorHandler: @escaping SpeechErrorHandler) {
        SpeechRecognition.requestAuthorization { [weak self] (authStatus) in
            guard let controller = self else { return }
            if authStatus {
                controller.recognize(textHandler: textHandler, errorHandler: errorHandler)
            } else {
                let errorMsg = "Speech recognizer needs to be authorized first"
                errorHandler(NSError(domain:"speechcontroller", code:1, userInfo:[NSLocalizedDescriptionKey: errorMsg]))
            }
        }
    }

    private var dictationString: Set<String> = Set()

    private func recognize(textHandler: @escaping SpeechRecognitionCompletion,
                           errorHandler: @escaping SpeechErrorHandler) {
        guard let node = SAudioKitServicesAp.shared.audioEngineInputNode else {
            return
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest!.requiresOnDeviceRecognition = false
        recognitionRequest!.shouldReportPartialResults = true

        node.installTap(onBus: 0,
                        bufferSize: SpeechRecognition.AUDIO_BUFFER_SIZE,
                        format: nil) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        speechTask = recognizer?.recognitionTask(with: recognitionRequest!) { [weak self] (result, error) in
            guard let `self` = self else { return }

            if let r = result {
                let transcription = r.bestTranscription
                let isFinal = r.isFinal

                var string = ""

                if isFinal {
                    self.reset()
                    string = transcription.formattedString
                    self.dictationString.insert(string)

                    if self.isRecognitionButtonSelected {
                        self.startRecognition(textHandler: textHandler,
                                              errorHandler: errorHandler)
                    }

                } else {
                    string = self.dictationString.joined() + " " + transcription.formattedString
                }

                textHandler(string, isFinal, nil)
                self.performFeedbackGenerator()

            } else {
                self.stopRecognition()
                errorHandler(error)
            }
        }
    }

    private func performFeedbackGenerator() {
        TapticEngine.selection.feedback()
    }

    /// Method which will stop the recording
    public func stopRecognition() {
        dictationString.removeAll()
        reset()
    }

    private func reset() {
        SAudioKitServicesAp.shared.removeAudioEngineInputNodeTap(onBus: 0)
        recognitionRequest?.endAudio()
        speechTask = nil
        recognitionRequest = nil
    }


    deinit {
        stopRecognition()
    }

    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        availabilityDidChangeCompletion?(available)
    }
}
