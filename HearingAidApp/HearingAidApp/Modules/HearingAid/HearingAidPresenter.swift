//
//  HearingAidPresenter.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 19.12.2022.
//

import Foundation
import AVFoundation

protocol HearingAidPresenterProtocol: AnyObject {
    
    var leftSliderLabelTitle: String { get }
    var rightSliderLabelTitle: String { get }
    var primaryButtonTitle: String { get }
    var buttonSubtitle: String { get }
    var sliderValue: Float { get }
    
    func viewDidLoad()
    func viewDidAppear()
    func viewWillDisappear()
    func viewDidLayoutSubviews()
    func didTapPrimaryButton()
    func didChangeBalanceSliderValue(to value: Double)
    func didChangeVolumeSliderPercentage(to percentage: Double)
}

final class HearingAidPresenter: HearingAidPresenterProtocol {
    
    // MARK: - Public Properties
    
    var leftSliderLabelTitle: String {
        return "Left".localized
    }
    
    var rightSliderLabelTitle: String {
        return "Right".localized
    }
    
    var primaryButtonTitle: String {
        return "Tap to \(isWorking ? "deactivate" : "activate")".localized
    }
    
    var buttonSubtitle: String {
        return (isWorking ? "Tap to end using hearing aid" : "Tap the button to get started").localized
    }
    
    var sliderValue: Float {
        return Float(audioService.balanceValue)
    }
    
    // MARK: - Private Properties
    private unowned let router: ApplicationRouterDelegate
    private unowned let view: HearingAidView
    private let audioService: AudioService
    private let purchasesService: PurchasesService
    private var wasShownMicrophonePermission = false
    private var wasShownConnectedHeadphones = false
    private var wasShownPaywall = false
    private var isWorking = false
    private var currentBalance = 0.0
    private var currentVolumePercentage = 0.0
    
    // MARK: - Object Lifecycle
    init(router: ApplicationRouterDelegate, view: HearingAidView, audioService: AudioService, purchasesService: PurchasesService) {
        self.router = router
        self.view = view
        self.audioService = audioService
        self.purchasesService = purchasesService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        view.configureForWorknigState(isWorking)
        view.configureLocalization()
        view.setTitleForOutputDeviceLabel(audioService.outputDeviceName)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeAudioRoute(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    func viewDidAppear() {
        if !audioService.hasAllowedMicrophoneUsage && !wasShownMicrophonePermission {
            router.performRoute(.microphonePermission)
            wasShownMicrophonePermission = true
        } else if !audioService.hasConnectedHeadphones && !wasShownConnectedHeadphones {
            router.performRoute(.headphonesConnection)
            wasShownConnectedHeadphones = true
        } else if !purchasesService.hasPremium && !wasShownPaywall {
            router.performRoute(.paywall)
            wasShownPaywall = true
        } else {
            audioService.configure()
            audioService.setAudioEngineEnabled(isWorking)
        }
    }
    
    func viewWillDisappear() {
        isWorking = false
        audioService.stop()
        view.configureLocalization()
        view.configureForWorknigState(isWorking)
    }
    
    func viewDidLayoutSubviews() {
        guard view.isVolumeViewConfigured == false else { return }
        view.isVolumeViewConfigured = true
        view.layoutIfNeeded()
        currentVolumePercentage = audioService.microphoneVolume * 100
        currentBalance = audioService.balanceValue
        view.configureVolumePercentageView(for: currentVolumePercentage)
        view.configureSliderFillView(for: currentBalance)
        view.configureScaleStackView(for: currentVolumePercentage)
    }
    
    func didTapPrimaryButton() {
        if !purchasesService.hasPremium || audioService.hearingAidUsingCount > 2 {
            router.performRoute(.paywall)
        } else if !audioService.hasAllowedMicrophoneUsage {
            router.performRoute(.microphonePermission)
        } else if !audioService.hasConnectedHeadphones {
            router.performRoute(.headphonesConnection)
        } else {
            isWorking.toggle()
            isWorking ? audioService.start() : audioService.stop()
            isWorking ? audioService.increaseCountOfUsingService() : Void()
            audioService.setAudioEngineEnabled(isWorking)
        }
        view.configureForWorknigState(isWorking)
    }
    
    func didChangeBalanceSliderValue(to value: Double) {
        guard currentBalance != value else { return }
        currentBalance = value
        view.configureSliderFillView(for: value)
        audioService.changeBalance(on: value)
    }
    
    func didChangeVolumeSliderPercentage(to percentage: Double) {
        if (1..<100).contains(percentage), currentVolumePercentage != percentage {
            currentVolumePercentage = percentage
            view.configureVolumePercentageView(for: percentage)
            audioService.changeVolume(on: percentage / 100.0)
        } else if ![0, 100, percentage].contains(currentVolumePercentage) {
            let newPercentage = percentage > 50 ? 100.0 : 0
            currentVolumePercentage = newPercentage
            view.configureVolumePercentageView(for: newPercentage)
            audioService.changeVolume(on: newPercentage / 100.0)
        }
    }
    
    // MARK: - Private Methods
    @objc private func didChangeAudioRoute(notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.setTitleForOutputDeviceLabel(self.audioService.outputDeviceName)
        }
    }
}
