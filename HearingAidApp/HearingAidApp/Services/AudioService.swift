//
//  AudioService.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 13.12.2022.
//

import UIKit
import AVFoundation
import AudioKit
import SoundpipeAudioKit
import SporthAudioKit
import AudioKitEX

final class AudioService {
    
    // MARK: - Public Properties
    @UserDefault("isMusicModeEnabled")
    var isMusicModeEnabled = false
    
    @UserDefault("shouldUseSystemVolume")
    var shouldUseSystemVolume = true
    
    @UserDefault("microphoneVolume")
    var microphoneVolume = 0.45
    
    @UserDefault("balanceValue")
    var balanceValue = 0.0
    
    @UserDefault("hearingAidUsingCount")
    private(set) var hearingAidUsingCount = 0
    
    var hasConnectedHeadphones: Bool {
        return Settings.headPhonesPlugged
    }
    
    var isMixerStarted: Bool {
        return mixer?.isStarted == true
    }
    
    var recordPermission: AVAudioSession.RecordPermission {
        return Settings.session.recordPermission
    }
    
    var hasAllowedMicrophoneUsage: Bool {
        return recordPermission == .granted
    }
    
    var outputDeviceName: String {
        return audioEngine?.outputDevice?.name ?? ""
    }
    
    var audioEngineInputNode: AVAudioInputNode? {
        if audioEngine?.avEngine.isRunning == false {
            try? audioEngine?.start()
        }
        return audioEngine?.avEngine.inputNode
    }
    
    var systemVolume: Double {
        return Double(Settings.session.outputVolume)
    }
    
    var didChangeVolumeCompletion: ((Double) -> Void)?
    var didChangeAmplitudeCompletion: ((Float) -> Void)?
    var didInitializeService: (() -> Void)?
    
    // MARK: - Private Properties
    private let logService: LogService
    private var audioEngine: AudioEngine?
    private var microphoneInput: AudioEngine.InputNode?
    private var panner: Panner?
    private var mixer: Mixer?
    private var currentAudioEngineMode = AudioEngineMode.hearingAid
    private var previousAudioEngineMode: (AudioEngineMode, isStarted: Bool)?
    private var isInitialized = false
    private var outputVolumeObserver: NSKeyValueObservation?
    private var sessionOptions: AVAudioSession.CategoryOptions {
        let musicModeOption: AVAudioSession.CategoryOptions = isMusicModeEnabled ? .mixWithOthers : .duckOthers
        let bluetoothOption: AVAudioSession.CategoryOptions = MicrophoneType.getCurrentMicrophone(hasConnectedHeadphones) == .headphones ? .allowBluetooth : .allowBluetoothA2DP
        return [musicModeOption, bluetoothOption]
    }
    
    // MARK: - Object Lifecycle
    init(logService: LogService) {
        self.logService = logService
    }
    
    // MARK: - Public Methods
    func requestMicrophoneUsagePermission(completion: ((Bool) -> Void)?) {
        if recordPermission == .denied, let url = URL(string: UIApplication.openSettingsURLString) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        } else {
            Settings.session.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion?(granted)
                }
            }
        }
    }
    
    func configure() {
        guard !isInitialized else { return }
        isInitialized = true
        
        audioEngine = AudioEngine()
        Settings.allowHapticsAndSystemSoundsDuringRecording = true
        try? Settings.setSession(category: .playAndRecord, with: sessionOptions)
        
        outputVolumeObserver = Settings.session.observe(\.outputVolume) { [weak self] session, value in
            self?.didChangeVolumeCompletion?(Double(Settings.session.outputVolume))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeAudioRoute(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
        
        guard let microphoneInput = audioEngine?.input else { return }
        let volume = shouldUseSystemVolume ? Double(Settings.session.outputVolume) : microphoneVolume
        let volumeValue = AUValue(max(1, volume * 5))
        microphoneInput.volume = volumeValue
        self.microphoneInput = microphoneInput
        
        let panner = Panner(microphoneInput)
        panner.$pan.value = AUValue(balanceValue)
        self.panner = panner
        
        let mixer = Mixer()
        mixer.addInput(panner)
        
        self.mixer = mixer
        audioEngine?.output = mixer
        
        changeMicrophone(on: MicrophoneType.getCurrentMicrophone(hasConnectedHeadphones))
        try? audioEngine?.start()
        setMixerEnabled(false)
        
        setAudioEngineEnabled(hasConnectedHeadphones)
        didInitializeService?()
    }
    
    func start() {
        print("[AudioService] - Try to start the service...")
        do {
            try audioEngine?.start()
            mixer?.start()
        } catch {
            print("[AudioService] - Error - \(error)")
        }
        print("[AudioService] - Successfully started.")
    }
    
    func stop() {
        audioEngine?.stop()
        print("[AudioService] - Stopped.")
    }
    
    func setMixerEnabled(_ isEnabled: Bool) {
        mixer?.volume = isEnabled ? 1 : 0
    }
    
    func setAudioEngineEnabled(_ isEnabled: Bool) {
        if !isInitialized && isEnabled {
            configure()
        } else {
            switch currentAudioEngineMode {
            case .hearingAid:
                setMixerEnabled(isEnabled)
            case .speechRecognition:
                setMixerEnabled(false)
            }
        }
    }
    
    func switchAudioEngineMode(to mode: AudioEngineMode) {
        guard isInitialized && mode != currentAudioEngineMode else { return }
        let isAudioEngineStarted = previousAudioEngineMode?.isStarted ?? false
        previousAudioEngineMode = (currentAudioEngineMode, currentAudioEngineMode == .hearingAid ? isMixerStarted : false)
        setAudioEngineEnabled(false)
        currentAudioEngineMode = mode
        setAudioEngineEnabled(isAudioEngineStarted)
    }
    
    func removeAudioEngineInputNodeTap(onBus bus: AVAudioNodeBus) {
        audioEngine?.avEngine.inputNode.removeTap(onBus: bus)
    }
    
    func changeMicrophone(on microphoneType: MicrophoneType) {
        switch microphoneType {
        case .bottom, .front, .back:
            let michrophone = AudioEngine.inputDevices[microphoneType.rawValue]
            MicrophoneType.setCurrentMicrophone(microphoneType)
            try? AudioEngine.setInputDevice(michrophone)
            guard !Settings.session.categoryOptions.contains(.allowBluetoothA2DP) else { return }
            audioEngine?.stop()
            try? Settings.setSession(category: .playAndRecord, with: sessionOptions)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                try? self?.audioEngine?.start()
            }
        case .headphones:
            MicrophoneType.setCurrentMicrophone(microphoneType)
            audioEngine?.stop()
            try? Settings.setSession(category: .playAndRecord, with: sessionOptions)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                try? self?.audioEngine?.start()
            }
        }
    }
    
    func changeVolume(on percehnageVolume: Double) {
        microphoneVolume = percehnageVolume
        guard microphoneInput?.isStarted == true else {
            return
        }
        let volumeValue = AUValue(max(1, percehnageVolume * 5))
        microphoneInput?.volume = volumeValue
    }
    
    func changeBalance(on value: Double) {
        logService.write(.🎧, "| Change volume balance from: \(balanceValue) to: \(value) |")
        balanceValue = value
        panner?.$pan.value = AUValue(value)
    }
    
    func increaseCountOfUsingService() {
        hearingAidUsingCount += 1
    }
    
    // MARK: - Private Methods
    @objc private func didChangeAudioRoute(notification: NSNotification) {
        guard let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt else { return }
        switch reason {
        case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
            guard audioEngine?.avEngine.isRunning == false else { return }
            try? audioEngine?.start()
        default:
            break
        }
    }
}

// MARK: - Supporting Types
enum AudioEngineMode {
    
    // MARK: - Cases
    case hearingAid
    case speechRecognition
}

enum MicrophoneType: Int, CaseIterable {
    
    // MARK: - Cases
    case bottom
    case front
    case back
    case headphones
    
    // MARK: - Static Properties
    static var defaultMicrophone = MicrophoneType.bottom
    
    static func getCurrentMicrophone(_ hasConnectedHeadphones: Bool) -> MicrophoneType {
        let rawValue = UserDefaults.standard.integer(forKey: "currentMicrophone")
        let savedMicrophoneType = MicrophoneType(rawValue: rawValue)!
        return savedMicrophoneType == .headphones && !hasConnectedHeadphones ? defaultMicrophone : savedMicrophoneType
    }
    
    static func setCurrentMicrophone(_ microphoneType: MicrophoneType) {
        UserDefaults.standard.set(microphoneType.rawValue, forKey: "currentMicrophone")
    }
}
