import UIKit
import MLKit
import Speech

typealias BTranslServicesNewCompletion = (String?) -> Void
typealias BTranslServicesNewDownloadCompletion = (Bool) -> Void

typealias TranslationLanguage = TranslateLanguage

final class BTranslServicesNew: NSObject {
    
    static let shared: BTranslServicesNew = BTranslServicesNew()
    
    // MARK: - Properties
    var inputLanguage: TranslationLanguage {
        get {
            let value = UserDefaults.standard.value(forKey: "inputTranslateLanguage") as? String ?? "en"
            return TranslationLanguage(rawValue: value)
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "inputTranslateLanguage")
        }
    }
    
    var outputLanguage: TranslationLanguage {
        get {
            let value = UserDefaults.standard.value(forKey: "currentTranslateLanguage") as? String ?? "de"
            return TranslationLanguage.allLanguages().first(where: { $0.rawValue == value }) ?? TranslationLanguage(rawValue: "de")
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "currentTranslateLanguage")
        }
    }
    
    var localizedInputLanguage: String {
        return Locale.current.localizedString(forIdentifier: inputLanguage.rawValue) ?? "Language"
    }
    
    var localizedOutputLanguage: String {
        return Locale.current.localizedString(forIdentifier: outputLanguage.rawValue) ?? "Language"
    }
    
    var inputLocale: Locale? {
        return CTranscribServicesAp.shared.supportedLocales.first(where: { $0.identifier.components(separatedBy: "-").first == inputLanguage.rawValue })
    }
    
    var outputLanguages: [TranslateLanguage] {
        return TranslateLanguage.allLanguages().sorted {
            return Locale.current.localizedString(forLanguageCode: $0.rawValue)! < Locale.current.localizedString(forLanguageCode: $1.rawValue)!
        }
    }
    
    var inputLanguages: [TranslateLanguage] {
        let filteredLanguages = TranslateLanguage.allLanguages().filter { translateLanguage in
            return CTranscribServicesAp.shared.supportedLocales.contains(where: { $0.identifier.components(separatedBy: "-").first == translateLanguage.rawValue })
        }
        return filteredLanguages.sorted {
            return Locale.current.localizedString(forLanguageCode: $0.rawValue)! < Locale.current.localizedString(forLanguageCode: $1.rawValue)!
        }
    }
    
    @Storage(key: "TranslateFromText", defaultValue: "")
    var translateFromText: String
    
    @Storage(key: "TranslateToText", defaultValue: "")
    var translateToText: String
    
    private var translator: Translator?
    private var modelManager: ModelManager?
    private var downloadCompletion: BTranslServicesNewDownloadCompletion?
    private var downloadingLanguages: [TranslateLanguage] = []
    
    // MARK: - Internal methods
    func prepareService() {
        let options = TranslatorOptions(sourceLanguage: inputLanguage, targetLanguage: outputLanguage)
        translator = Translator.translator(options: options)
        modelManager = ModelManager.modelManager()
        
        if !KAppConfigServic.shared.settings.outputLanguageSetted {
            let phoneInputLanguage = TranslationLanguage.allLanguages().first(where: { $0.rawValue == CTranscribServicesAp.shared.selectedLocale.components(separatedBy: "-").first ?? "en" }) ?? TranslationLanguage(rawValue: "en")
            outputLanguage = TranslationLanguage(rawValue: phoneInputLanguage.rawValue == "en" ? "de" : "en")
            inputLanguage = inputLanguages.contains(where: { $0.rawValue == phoneInputLanguage.rawValue }) ? phoneInputLanguage : TranslationLanguage(rawValue: "en")
            KAppConfigServic.shared.settings.outputLanguageSetted = true
        }
        
        downloadModel(language: inputLanguage, completion: nil)
        downloadModel(language: outputLanguage, completion: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(remoteModelDownloadDidComplete(notification:)), name: .mlkitModelDownloadDidSucceed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(remoteModelDownloadDidComplete(notification:)), name: .mlkitModelDownloadDidFail, object: nil)
    }
    
    func changeOutputLanguage(on language: TranslationLanguage) {
        outputLanguage = language
    }
    
    func changeInputLanguage(on language: TranslationLanguage) {
        inputLanguage = language
        if let inputLocale = CTranscribServicesAp.shared.supportedLocales.first(where: { $0.identifier.components(separatedBy: "-").first == language.rawValue }) {
            CTranscribServicesAp.shared.stopRecognition()
            CTranscribServicesAp.shared.chargeRecognation(on: inputLocale)
        }
    }
    
    func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool {
        return modelManager?.isModelDownloaded(model(for: language)) ?? false
    }
    
    func isLanguageDownloading(_ language: TranslateLanguage) -> Bool {
        return downloadingLanguages.contains(language)
    }
    
    func downloadModel(language: TranslateLanguage, completion: BTranslServicesNewDownloadCompletion?) {
        downloadCompletion = completion
        let model = model(for: language)

        if language == .english {
            downloadCompletion?(true)
            return
        }

        if modelManager?.isModelDownloaded(model) == true {
            downloadCompletion?(true)
            return
        }

        downloadingLanguages.append(language)
        let conditions = ModelDownloadConditions(allowsCellularAccess: true, allowsBackgroundDownloading: true)
        modelManager?.download(model, conditions: conditions)
    }
    
    func translate(text: String, completion: @escaping (String) -> Void) {
        let options = TranslatorOptions(sourceLanguage: inputLanguage, targetLanguage: outputLanguage)
        translator = Translator.translator(options: options)

        translator?.downloadModelIfNeeded { [weak self] error in
            guard error == nil else {
                completion("")
                return
            }

            self?.translator?.translate(text) { result, error in
                guard error == nil else {
                    completion("")
                    return
                }

                completion(result ?? "")
            }
        }
    }
    
    // MARK: - Private methods
    private func model(for language: TranslateLanguage) -> TranslateRemoteModel {
        return TranslateRemoteModel.translateRemoteModel(language: language)
    }
    
    @objc private func remoteModelDownloadDidComplete(notification: NSNotification) {
        guard let remoteModel = notification.userInfo?[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.downloadingLanguages.remove(remoteModel.language)
            self.downloadCompletion?(notification.name == .mlkitModelDownloadDidSucceed)
        }
    }
}
