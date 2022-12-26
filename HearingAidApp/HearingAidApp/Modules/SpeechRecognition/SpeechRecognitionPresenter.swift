//
//  SpeechRecognitionPresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 20.12.2022.
//

import UIKit

protocol SpeechRecognitionPresenterProtocol: AnyObject {
    
    var currentLanguage: String { get }
    
    func viewDidLoad()
    func viewDidAppear()
    func viewWillDisappear()
    func didTapChangeLanguageButton()
    func didTapMicroButton()
}

final class SpeechRecognitionPresenter: SpeechRecognitionPresenterProtocol {
    
    // MARK: - Public Properties
    var currentLanguage: String { speechRecognitionService.localizedSelectedLanguage().capitalized }
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view: SpeechRecognitionView
    private let audioService: AudioService
    private let speechRecognitionService: SpeechRecognitionService
    private let purchasesService: PurchasesService
    private var wasShownSpeechRecognitionPermission = false
    private var isWorking = false
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: SpeechRecognitionView, audioService: AudioService, speechRecognitionService: SpeechRecognitionService, purchasesService: PurchasesService) {
        self.router = router
        self.view = view
        self.audioService = audioService
        self.speechRecognitionService = speechRecognitionService
        self.purchasesService = purchasesService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.configureUIForWorkingState(false)
        view.configureLocalization()
        audioService.configure()
        speechRecognitionService.setAudioService(audioService)
    }
    
    func viewDidAppear() {
        if !speechRecognitionService.hasAllowedSpeechRecognition && !wasShownSpeechRecognitionPermission {
            router.performRoute(.speechRecognitionPermission)
            wasShownSpeechRecognitionPermission = true
        } else {
            audioService.switchAudioEngineMode(to: .speechRecognition)
        }
    }
    
    func viewWillDisappear() {
        // TODO: - Disable Services
    }
    
    func didTapChangeLanguageButton() {
        isWorking = false
        audioService.setAudioEngineEnabled(false)
        UIApplication.shared.isIdleTimerDisabled = false
        speechRecognitionService.stopRecognition()
        view.configureUIForWorkingState(isWorking)
        router.performRoute(.languagesList(dismissAction: { [weak self] locale in
            guard let self = self else { return }
            self.speechRecognitionService.setLocale(locale)
            self.view.configureUIForWorkingState(self.isWorking)
        }))
    }
    
    func didTapMicroButton() {
        if !purchasesService.hasPremium && speechRecognitionService.countOfUsingService > 3 {
            router.performRoute(.paywall)
        } else if !speechRecognitionService.hasAllowedSpeechRecognition {
            router.performRoute(.speechRecognitionPermission)
        } else if !audioService.hasAllowedMicrophoneUsage {
            router.performRoute(.microphonePermission)
        } else {
            isWorking.toggle()
            speechRecognitionService.stopRecognition()
            
            if isWorking {
                audioService.setAudioEngineEnabled(true)
                UIApplication.shared.isIdleTimerDisabled = true
                let readyText = "Go ahead, I'm listening :)".localized
                view.setTextForTextView(readyText)
                speechRecognitionService.startRecognition { [weak self] text, _, _ in
                    DispatchQueue.main.async {
                        self?.view.setTextForTextView(text)
                    }
                } errorHandler: { [weak self] error in
                    DispatchQueue.main.async {
                        self?.view.showAlert(title: "Oops".localized,
                                              message: "Something went wrong. Please try again".localized,
                                              defaultActionTitle: "Ok".localized,
                                              destructiveActionTitle: nil)
                    }
                }
                speechRecognitionService.increaseCountOfUsingService()
            } else {
                audioService.setAudioEngineEnabled(false)
                UIApplication.shared.isIdleTimerDisabled = false
                speechRecognitionService.stopRecognition()
            }
            
            view.configureUIForWorkingState(isWorking)
        }
    }
}
