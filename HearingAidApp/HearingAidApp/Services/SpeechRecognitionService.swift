//
//  SpeechRecognitionService.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 13.12.2022.
//

import UIKit
import Speech
import AudioKit

final class SpeechRecognitionService: NSObject {
    
    // MARK: - Public Properties
    var speechRecognizerAvailabilityDidChange: ((Bool) -> Void)?
    var isWorking = false
    
    @UserDefault("countOfUsingSpeechRecognition")
    private(set) var countOfUsingService = 0
    
    // MARK: - Private Properties
    private var audioService: AudioService?
    private let audioBufferSize: UInt32 = 1024
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechTask: SFSpeechRecognitionTask?
    private var distationString = Set<String>()
    private var currentSelectedLocale: String {
        get {
            var defaultLocale = "en-US"
            if SFSpeechRecognizer.supportedLocales().contains(.current) {
                defaultLocale = Locale.current.identifier
            } else if let preferredLocale = SFSpeechRecognizer.supportedLocales().first(where: { $0.identifier.components(separatedBy: "-").first == Locale.current.identifier.components(separatedBy: "-").first }) {
                defaultLocale = preferredLocale.identifier
            }
            return UserDefaults.standard.value(forKey: "currentSelectedLocale") as? String ?? defaultLocale
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "currentSelectedLocale")
        }
    }
    
    var hasAllowedSpeechRecognition: Bool {
        return SFSpeechRecognizer.authorizationStatus() == .authorized
    }
    
    // MARK: - Object Lifecycle
    override init() {
        audioService = nil
        super.init()
        let locale = Locale(identifier: currentSelectedLocale)
        setLocale(locale)
    }
    
    deinit {
        stopRecognition()
    }
    
    func setLocale(_ locale: Locale) {
        stopRecognition()
        recognizer = SFSpeechRecognizer(locale: locale)
        recognizer?.delegate = self
        recognizer?.defaultTaskHint = .dictation
        currentSelectedLocale = locale.identifier
    }
    
    func setAudioService(_ audioService: AudioService) {
        self.audioService = audioService
    }
    
    func startRecognition(completionHandler: @escaping (String, Bool, Any?) -> Void, errorHandler: @escaping (Error?) -> Void) {
        requestSpeechRecognitionUsagePermission { [weak self] authorazied in
            guard let self = self else {
                return
            }
            guard authorazied else {
                let errorMessage = "Speech recognizer needs to be authorized first"
                let error = NSError(domain: "SpeechRecognition", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                errorHandler(error)
                return
            }
            self.recognize(completionHandler: completionHandler, errorHandler: errorHandler)
        }
    }
    
    func stopRecognition() {
        distationString.removeAll()
        reset()
    }
    
    func supportedLocales() -> [Locale] {
        return Array(SFSpeechRecognizer.supportedLocales().sorted(by: { $0.identifier < $1.identifier }))
    }
    
    func localizedSelectedLanguage() -> String {
        guard let locale = supportedLocales().filter({ $0.identifier == currentSelectedLocale }).first else { return "Language" }
        return locale.localizedString(forIdentifier: locale.identifier) ?? "Language"
    }
    
    func requestSpeechRecognitionUsagePermission(completion: ((Bool) -> Void)?) {
        DispatchQueue.main.async {
            if SFSpeechRecognizer.authorizationStatus() == .denied, let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            } else {
                SFSpeechRecognizer.requestAuthorization { authStatus in
                    completion?(authStatus == .authorized)
                }
            }
        }
    }
    
    func increaseCountOfUsingService() {
        countOfUsingService += 1
    }
    
    // MARK: - Private Methods
    private func recognize(completionHandler: @escaping (String, Bool, Any?) -> Void, errorHandler: @escaping (Error?) -> Void) {
        guard let node = audioService?.audioEngineInputNode else {
            return
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.requiresOnDeviceRecognition = false
        recognitionRequest?.shouldReportPartialResults = true
        node.installTap(onBus: 0, bufferSize: audioBufferSize, format: nil) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        speechTask = recognizer?.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            guard let self = self, let result = result else {
                self?.stopRecognition()
                errorHandler(error)
                return
            }
            let transcription = result.bestTranscription
            let isFinal = result.isFinal
            var string = ""
            
            if isFinal {
                self.reset()
                string = transcription.formattedString
                self.distationString.insert(string)
                if self.isWorking {
                    self.startRecognition(completionHandler: completionHandler, errorHandler: errorHandler)
                }
            } else {
                string = self.distationString.joined() + " " + transcription.formattedString
            }
            
            completionHandler(string, isFinal, nil)
        }
    }
    
    private func reset() {
        audioService?.removeAudioEngineInputNodeTap(onBus: 0)
        recognitionRequest?.endAudio()
        speechTask = nil
        recognitionRequest = nil
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension SpeechRecognitionService: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        speechRecognizerAvailabilityDidChange?(available)
    }
}
