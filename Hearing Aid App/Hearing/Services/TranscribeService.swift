import UIKit
import Speech

typealias TranscribeServicePermissionCompletion = (Bool) -> Void
typealias TranscribeServiceSpeechRecognitionCompletion = (String) -> Void
typealias TranscribeServiceSpeechErrorCompletion = (Error?) -> Void

struct TranscribeModel: Codable {
    var title: String
    var createdDate: TimeInterval
}

final class TranscribeService: NSObject {
    
    // MARK: - Properties
    static let shared: TranscribeService = TranscribeService()
    static let TAG: String = "TranscribeService"
    
    @Storage(key: "ShakeToClearText", defaultValue: false)
    private(set) var isShakeToClear: Bool
    
    @Storage(key: "OfflineTranslate", defaultValue: true)
    private(set) var isOfflineTranslate: Bool
    
    @Storage(key: "TypeText", defaultValue: "")
    var typeText: String
    
    @Storage(key: "TranscribeText", defaultValue: "")
    var transcribeText: String
    
    @Storage(key: "SavedTranscripts", defaultValue: [])
    var savedTranscripts: [TranscribeModel]
    
    var isStartedTranscribe: Bool = false
    var availabilityRecognition: TranscribeServicePermissionCompletion?
    
    private(set) var selectedLocale: String {
        get {
            var defaultLocale = "en-US"
            if SFSpeechRecognizer.supportedLocales().contains(Locale.current) {
                defaultLocale = Locale.current.identifier
            } else if let preferredLocale = SFSpeechRecognizer.supportedLocales().first(where: { $0.identifier.components(separatedBy: "-").first == Locale.current.identifier.components(separatedBy: "_").first }) {
                defaultLocale = preferredLocale.identifier
            }
            return UserDefaults.standard.value(forKey: "currentSelectedLocale") as? String ?? defaultLocale
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "currentSelectedLocale")
        }
    }
    
    var recordPermission: SFSpeechRecognizerAuthorizationStatus {
        return SFSpeechRecognizer.authorizationStatus()
    }
    
    var supportedLocales: [Locale] {
        return Array(SFSpeechRecognizer.supportedLocales()).sorted(by: { $0.identifier < $1.identifier})
    }
    
    var localizedSelectedLocale: String {
        guard let locale = supportedLocales.filter({ $0.identifier == selectedLocale }).first else {
            return "Language"
        }
        return Locale.current.localizedString(forIdentifier: locale.identifier) ?? "Language"
    }
    
    private var speechRecognition: SFSpeechRecognizer?
    private var speechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private var dictation: [String] = []
    private var isSaveRecognitionText: Bool = false
    
    // MARK: - Methods
    func requestRecognitionPermission(completion: AVServicePermissionCompletion?) {
        if recordPermission == .denied, let url = URL(string: UIApplication.openSettingsURLString) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, completionHandler: nil)
            }
        } else {
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        completion?(true)
                    case .denied, .restricted, .notDetermined:
                        completion?(false)
                    @unknown default:
                        completion?(false)
                    }
                }
            }
        }
    }
    
    func chargeRecognation(on locale: Locale? = nil) {
        speechRecognition = SFSpeechRecognizer(locale: locale ?? Locale(identifier: selectedLocale))
        speechRecognition?.delegate = self
        speechRecognition?.defaultTaskHint = .dictation
    }
    
    func recognize(_ completion: @escaping TranscribeServiceSpeechRecognitionCompletion, _ errorCompletion: @escaping TranscribeServiceSpeechErrorCompletion) {
        guard let inputNode = AudioKitService.shared.audioEngineInputNode else {
            return
        }
        speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        speechRecognitionRequest?.requiresOnDeviceRecognition = false
        speechRecognitionRequest?.shouldReportPartialResults = true
        isSaveRecognitionText = false
        
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: nil) { [weak self] buffer, _ in
            self?.speechRecognitionRequest?.append(buffer)
        }
        
        guard let request = speechRecognitionRequest else {
            errorCompletion(nil)
            return
        }
        
        speechRecognitionTask = speechRecognition?.recognitionTask(with: request) { [weak self] (result, error) in
            guard let self = self, let result = result, error == nil else {
                self?.stopRecognition()
                return
            }
            let transcription = result.bestTranscription
            let isFinal = result.isFinal
            var string = ""
            
            if isFinal {
                self.speechRecognitionTask != nil ? self.stopRecognition() : Void()
                let prefixText = self.dictation.joined().isEmpty ? "" : self.dictation.joined() + " "
                string = prefixText + transcription.formattedString
                
                self.isSaveRecognitionText || self.isStartedTranscribe ? self.insertToDictionary(new: transcription.formattedString) : Void()
                
                if self.isStartedTranscribe == true {
                    self.recognize(completion, errorCompletion)
                }
            } else {
                let prefixText = self.dictation.joined().isEmpty ? "" : self.dictation.joined() + " "
                string = prefixText + transcription.formattedString
            }
            
            DispatchQueue.main.async {
                TranscribeService.shared.isStartedTranscribe ? completion(string) : Void()
            }
            TapticEngine.selection.feedback()
        }
    }
    
    func cleanDictionary() {
        dictation.removeAll()
    }
    
    func insertToDictionary(new string: String) {
        guard dictation.contains(where: { $0 == string }) == false else {
            return
        }
        dictation.append(string)
    }
    
    func stopRecognition(isSaveRecognitionText: Bool = false) {
        self.isSaveRecognitionText = isSaveRecognitionText
        AudioKitService.shared.removeAudioEngineInputNodeTap(onBus: 0)
        speechRecognitionRequest?.endAudio()
//        speechRecognitionTask?.cancel()
        speechRecognitionTask = nil
        speechRecognitionRequest = nil
    }
    
    func changeLocale(on locale: Locale) {
        stopRecognition()
        selectedLocale = locale.identifier
        chargeRecognation(on: locale)
    }
    
    func setShakeToClear(_ asEnabled: Bool) {
        isShakeToClear = asEnabled
    }
    
    func setOfflineTranslate(_ asEnabled: Bool) {
        isOfflineTranslate = asEnabled
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension TranscribeService: SFSpeechRecognizerDelegate {
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        availabilityRecognition?(available)
    }
}
