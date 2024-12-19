import UIKit
import Speech

typealias CTranscribServicesApPermissionCompletion = (Bool) -> Void
typealias CTranscribServicesApSpeechRecognitionCompletion = (String) -> Void
typealias CTranscribServicesApSpeechErrorCompletion = (Error?) -> Void

struct TranscribeModel: Codable {
    var title: String
    var createdDate: TimeInterval
}

final class CTranscribServicesAp: NSObject {
    
    // MARK: - Properties
    static let shared: CTranscribServicesAp = CTranscribServicesAp()
    static let TAG: String = "CTranscribServicesAp"
    
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
    
    @Storage(key: "ShowGetStartedView", defaultValue: true)
    var isShowGetStartedView: Bool
    
    @Storage(key: "SavedFirstTranscripts", defaultValue: false)
    var isSavedFirstTranscripts: Bool
    
    var isStartedTranscribe: Bool = false
    var availabilityRecognition: CTranscribServicesApPermissionCompletion?
    
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
    
    var supportedLocalesWithSelectedLocale: [Locale] {
        let locales = Array(SFSpeechRecognizer.supportedLocales())
        let sortedLocales = locales.sorted {
            if $0.identifier == selectedLocale {
                return true
            } else if $1.identifier == selectedLocale {
                return false
            }
            return $0.identifier < $1.identifier
        }
        return sortedLocales
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
        if recordPermission == .denied {
            completion?(false)
        } else {
            KAppConfigServic.shared.analytics.track(action: .permissionViewed, with: [
                "type" : "speech_recognition"
            ])
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        completion?(true)
                        KAppConfigServic.shared.analytics.track(action: .permissionGranted, with: [
                            "type" : "speech_recognition"
                        ])
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
    
    func recognize(_ completion: @escaping CTranscribServicesApSpeechRecognitionCompletion, _ errorCompletion: @escaping CTranscribServicesApSpeechErrorCompletion) {
        guard let inputNode = SAudioKitServicesAp.shared.audioEngineInputNode else {
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
                CTranscribServicesAp.shared.isStartedTranscribe ? completion(string) : Void()
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
        SAudioKitServicesAp.shared.removeAudioEngineInputNodeTap(onBus: 0)
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
extension CTranscribServicesAp: SFSpeechRecognizerDelegate {
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        availabilityRecognition?(available)
    }
}
