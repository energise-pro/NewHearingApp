import UIKit
import AVFoundation
import AudioKit
import SoundpipeAudioKit
import SporthAudioKit
import AudioKitEX
import SwiftUI

enum AudioEngineMode {
    case aid
    case recognize
}

enum FeatureMode {
    case aid
    case recognize
    case translate
}

typealias AVServicePermissionCompletion = (Bool) -> Void

final class AudioKitService {
    
    // MARK: - Properties
    static let shared: AudioKitService = AudioKitService()
    static let TAG: String = "AVService"
    
    @Storage(key: "noseOFF_Enabeld", defaultValue: true)
    var isNoiseOffEnabled: Bool
    
    @Storage(key: "stereoEnabled", defaultValue: false)
    var isStereoEnabled: Bool
    
    @Storage(key: "MusicMode", defaultValue: false)
    var isMusicModeEnabled: Bool
    
    @Storage(key: "SystemVolume", defaultValue: true)
    var isUseSystemVolume: Bool
    
    @Storage(key: "ClearVoice", defaultValue: false)
    var isClearVoice: Bool
    
    @Storage(key: "Reverb.isStarted", defaultValue: false)
    var isTemplatesEnabled: Bool
    
    @Storage(key: "Compressor.isStarted", defaultValue: true)
    var isCompressorEnabled: Bool
    
    @Storage(key: "VoiceChanger.isStarted", defaultValue: false)
    var isVoiceChangerEnabled: Bool
    
    @Storage(key: "Limiter.isStarted", defaultValue: true)
    var isLimiterEnabled: Bool
    
    @Storage(key: "Equalizer.isEnabled", defaultValue: false)
    var isEqualizedEnabled: Bool
    
    @Storage(key: "microphoneVolume", defaultValue: 0.45)
    var microphoneVolume: Double
    
    @Storage(key: "Balance", defaultValue: 0.0)
    var balanceValue: Double
    
    @Storage(key: "countOfUsingAid", defaultValue: 0)
    var countOfUsingAid: Int
    
    @Storage(key: "countOfUsingRecognize", defaultValue: 0)
    var countOfUsingRecognize: Int
    
    @Storage(key: "countOfTranslate", defaultValue: 0)
    var countOfTranslate: Int
    
    var connectedHeadphones: Bool {
        return Settings.headPhonesPlugged
    }
    
    var isStartedMixer: Bool {
        return mixer?.isStarted == true
    }
    
    var recordPermission: AVAudioSession.RecordPermission {
        return Settings.session.recordPermission
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
    var didInitialiseService: (() -> Void)?
    
    // MARK: - Private peroperties
    private var audioEngine: AudioEngine?
    private var microphoneInput: AudioEngine.InputNode?
    private var panner: Panner?
    private var hightPassFilter: HighPassFilter?
    private var lowPassFilter: LowPassFilter?
    private var stereoEffect: OperationEffect?
    private var pitchShifter: PitchShifter?
    
    private var compressor: Compressor?
    private var reverb: Reverb?
    private var peakLimiter: PeakLimiter?
    private var mixer: Mixer?
    private var amplitudeTap: AmplitudeTap?
    private(set) var equalizer: EqualizerMixer?
    private(set) var microphoneRollingView: NodeRollingView?
    
    private var currentMode: AudioEngineMode = .aid
    private var previousMode: (mode: AudioEngineMode, isStarted: Bool)?
    private var isInitialized: Bool = false
    private var outputVolumeObserve: NSKeyValueObservation?
    private var sessionOptions: AVAudioSession.CategoryOptions {
        let musicModeOption: AVAudioSession.CategoryOptions = isMusicModeEnabled ? .mixWithOthers : .duckOthers
        let bluetoothOption: AVAudioSession.CategoryOptions = MicrophoneType.selectedMicrophone == .headphones ? .allowBluetooth : .allowBluetoothA2DP
        return [musicModeOption, bluetoothOption]
    }
    
    // MARK: - Internal methods
    func requestMicrophonePermission(completion: AVServicePermissionCompletion?) {
        if recordPermission == .denied, let url = URL(string: UIApplication.openSettingsURLString) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, completionHandler: nil)
            }
        } else {
            Settings.session.requestRecordPermission { accepted in
                DispatchQueue.main.async {
                    completion?(accepted)
                }
                Logger.log(tag: AudioKitService.TAG, message: "Microphone permission was \(accepted ? "accepted" : "declined")")
            }
        }
    }
    
    func initializeAudioKit() {
        guard !isInitialized else {
            return
        }
        isInitialized = true
        
        audioEngine = AudioEngine()
        
        Settings.allowHapticsAndSystemSoundsDuringRecording = true
        try? Settings.setSession(category: .playAndRecord, with: sessionOptions)
        outputVolumeObserve = Settings.session.observe(\.outputVolume) { [weak self] session, value in
            self?.didChangeVolumeCompletion?(Double(Settings.session.outputVolume))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
        
        guard let microphoneInput = audioEngine?.input else {
            return
        }
        
        let volume = isUseSystemVolume ? Double(Settings.session.outputVolume) : microphoneVolume
        let volumeValue = AUValue(max(1, volume * 5))
        microphoneInput.volume = volumeValue
        self.microphoneInput = microphoneInput
        
        // For controlling balance parameter
        let panner = Panner(microphoneInput)
        panner.$pan.value = AUValue(balanceValue)
        self.panner = panner
        
        // For controlling noise parameter
        let hightPassFilter = HighPassFilter(panner)
        hightPassFilter.$cutoffFrequency.value = isNoiseOffEnabled ? 1000 : 100
        hightPassFilter.$resonance.value = -20
        self.hightPassFilter = hightPassFilter
        
        let lowPassFilter = LowPassFilter(hightPassFilter)
        lowPassFilter.$cutoffFrequency.value = isNoiseOffEnabled ? 4000 : 15000
        lowPassFilter.$resonance.value = -20
        self.lowPassFilter = lowPassFilter
        
        let pitchShifter = PitchShifter(lowPassFilter)
        self.pitchShifter = pitchShifter
        PitchShifterParameter.allCases.forEach { changePitchShifterValue(on: $0.value, for: $0) }
        isVoiceChangerEnabled ? pitchShifter.start() : pitchShifter.stop()
        
        // For controlling stereo parameter
        let stereoEffect = OperationEffect(pitchShifter) { input, parameters in
            let mixValue = 0.3
            let parameter = "\(input) dup \(1 - mixValue) * swap 0 \(0.95) 0.1 vdelay \(mixValue) * +"
            return StereoOperation(parameter)
        }
        self.stereoEffect = stereoEffect
        
        // For controlling equalizer parameter
        let equalizer = EqualizerMixer(input: stereoEffect)
        self.equalizer = equalizer
        
        // For controlling compressor parameter
        let compressor = Compressor(equalizer.outputNode)
        self.compressor = compressor
        
        // For controlling reverb parameter
        let reverb = Reverb(compressor)
        self.reverb = reverb
        changeTemplate(on: TemplatesType.selectedTemplate)
        isTemplatesEnabled ? reverb.start() : reverb.stop()
        
        // For controlling limiter parameter
        let limiter = PeakLimiter(reverb)
        self.peakLimiter = limiter
        
        // For mixing all nodes
        let mixer = Mixer()
        mixer.addInput(limiter)
        
        let amplitudeTap = AmplitudeTap(microphoneInput) { [weak self] value in
            self?.didChangeAmplitudeCompletion?(value)
        }
        
        self.amplitudeTap = amplitudeTap
        
        self.mixer = mixer
        audioEngine?.output = mixer
        
        // For UI plot view
        createRollingView()
        
        changeMicrophone(on: MicrophoneType.selectedMicrophone)
        try? audioEngine?.start()
        setMixer(false)
        
        requestMicrophonePermission { [weak self] _ in
            self?.setAudioEngine(self?.connectedHeadphones ?? false)
            self?.didInitialiseService?()
        }
        
        !isStereoEnabled ? stereoEffect.stop() : Void()
        !isEqualizedEnabled ? equalizer.stop() : Void()
    }
    
    func createRollingView() {
        guard let inputNode = audioEngine?.input else {
            return
        }
        let microphoneRollingView = NodeRollingView(inputNode, color: Color(ThemeService.shared.activeColor.cgColor), backgroundColor: ThemeService.shared.isDarkModeEnabled ? .black : .white)
        self.microphoneRollingView = microphoneRollingView
        DispatchQueue.main.async { [weak self] in
            self?.isStartedMixer == true ? self?.microphoneRollingView?.nodeTap.start() : self?.microphoneRollingView?.nodeTap.stop()
        }
    }
    
    func setAudioEngine(_ asEnabled: Bool) {
        if !isInitialized && asEnabled {
            initializeAudioKit()
        } else {
            switch currentMode {
            case .aid:
                setMixer(asEnabled)
                DispatchQueue.main.async { [weak self] in
                    asEnabled ? self?.microphoneRollingView?.nodeTap.start() : self?.microphoneRollingView?.nodeTap.stop()
                }
//                asEnabled ? amplitudeTracker?.start() : amplitudeTracker?.stop()
            case .recognize:
//                asEnabled ? amplitudeTracker?.start() : amplitudeTracker?.stop()
                setMixer(false)
                microphoneRollingView?.nodeTap.stop()
            }
        }
    }
    
    func setMixer(_ asEnabled: Bool) {
        mixer?.volume = asEnabled ? 1 : 0
    }
    
    func switchAudioEngine(_ mode: AudioEngineMode) {
        guard isInitialized, mode != currentMode else {
            return
        }
        let isStartedAudioEngine = previousMode?.isStarted ?? false
        previousMode = (mode: currentMode, isStarted: currentMode == .aid ? isStartedMixer : false)
        setAudioEngine(false)
        currentMode = mode
        setAudioEngine(isStartedAudioEngine)
    }
    
    func setNoiseOFF(_ asEnabled: Bool) {
        isNoiseOffEnabled = asEnabled
        hightPassFilter?.$cutoffFrequency.value = isNoiseOffEnabled ? 1000 : 100
        lowPassFilter?.$cutoffFrequency.value = isNoiseOffEnabled ? 4000 : 15000
    }
    
    func setStereo(_ asEnabled: Bool) {
        isStereoEnabled = asEnabled
        guard isStartedMixer else {
            return
        }
        asEnabled ? stereoEffect?.start() : stereoEffect?.stop()
    }
    
    func setMusicMode(_ asEnabled: Bool) {
        isMusicModeEnabled = asEnabled
        guard isInitialized else {
            return
        }
        audioEngine?.stop()
        try? Settings.setSession(category: .playAndRecord, with: sessionOptions)
        try? audioEngine?.start()
    }
    
    func setUseSystemVolume(_ asEnabled: Bool) {
        isUseSystemVolume = asEnabled
        guard microphoneInput?.isStarted == true else {
            return
        }
        let volume = asEnabled ? Double(Settings.session.outputVolume) : microphoneVolume
        let volumeValue = AUValue(max(1, volume * 5))
        microphoneInput?.volume = volumeValue
        microphoneVolume = volume
    }
    
    func setClearVoice(_ asEnabled: Bool) {
        isClearVoice = asEnabled
    }
    
    func setTemplates(_ asEnabled: Bool) {
        isTemplatesEnabled = asEnabled
        asEnabled ? reverb?.start() : reverb?.stop()
    }
    
    func setCompressor(_ asEnabled: Bool) {
        isCompressorEnabled = asEnabled
        asEnabled ? compressor?.start() : compressor?.stop()
    }
    
    func setVoiceChanger(_ asEnabled: Bool) {
        isVoiceChangerEnabled = asEnabled
        asEnabled ? pitchShifter?.start() : pitchShifter?.stop()
    }
    
    func setLimiter(_ asEnabled: Bool) {
        isLimiterEnabled = asEnabled
        asEnabled ? peakLimiter?.start() : peakLimiter?.stop()
    }
    
    func setEqualizer(_ asEnabled: Bool) {
        isEqualizedEnabled = asEnabled
        asEnabled ? equalizer?.start() : equalizer?.stop()
    }
    
    func changeTemplate(on template: TemplatesType) {
        TemplatesType.selectedTemplate = template
        guard let preset = AVAudioUnitReverbPreset(rawValue: template.rawValue) else {
            return
        }
        reverb?.loadFactoryPreset(preset)
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
        balanceValue = value
        panner?.$pan.value = AUValue(value)
    }
    
    func changeMicrophone(on microphoneType: MicrophoneType) {
        switch microphoneType {
        case .bottom, .front, .back:
            let michrophone = AudioEngine.inputDevices[safe: microphoneType.rawValue]
            guard let michrophone = michrophone else {
                return
            }
            MicrophoneType.selectedMicrophone = microphoneType
            try? AudioEngine.setInputDevice(michrophone)
            guard !Settings.session.categoryOptions.contains(.allowBluetoothA2DP) else {
                return
            }
            audioEngine?.stop()
            try? Settings.setSession(category: .playAndRecord, with: sessionOptions)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                try? self?.audioEngine?.start()
            }
        case .headphones:
            MicrophoneType.selectedMicrophone = microphoneType
            audioEngine?.stop()
            try? Settings.setSession(category: .playAndRecord, with: sessionOptions)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                try? self?.audioEngine?.start()
            }
        }
    }
    
    func changeTemplatesVolume(on value: Double) {
        TemplatesParameter.dryWet.setNew(value)
        reverb?.dryWetMix = AUValue(value)
    }
    
    func changeCompressorValue(on value: Double, for parameter: CompressorParameter) {
        parameter.setNew(value)
        switch parameter {
        case .threshold:
            compressor?.$threshold.value = AUValue(value)
        case .attackDuration:
            compressor?.$attackTime.value = AUValue(value)
        case .releaseDuration:
            compressor?.$releaseTime.value = AUValue(value)
        case .masterGain:
            compressor?.$masterGain.value = AUValue(value)
        }
    }
    
    func changePitchShifterValue(on value: Double, for parameter: PitchShifterParameter) {
        parameter.setNew(value)
        switch parameter {
        case .shift:
            pitchShifter?.$shift.ramp(to: AUValue(value), duration: 0.02)
        case .windowSize:
            pitchShifter?.$windowSize.ramp(to: AUValue(value), duration: 0.02)
        case .crossFade:
            pitchShifter?.$crossfade.ramp(to: AUValue(value), duration: 0.02)
        }
    }
    
    func changeLimiterValue(on value: Double, for parameter: PeakLimiterParameter) {
        parameter.setNew(value)
        switch parameter {
        case .attackDuration:
            peakLimiter?.$attackTime.value = AUValue(value)
        case .decayDuration:
            peakLimiter?.$decayTime.value = AUValue(value)
        case .preGain:
            peakLimiter?.$preGain.value = AUValue(value)
        }
    }
    
    func removeAudioEngineInputNodeTap(onBus bus: AVAudioNodeBus) {
        audioEngine?.avEngine.inputNode.removeTap(onBus: bus)
    }
    
    func overrideOutputAudioPort(on port: AVAudioSession.PortOverride) {
        try? Settings.setSession(category: .playback, with: sessionOptions)
        try? Settings.session.overrideOutputAudioPort(port)
    }
    
    func increaseCountOfUsing(for engineMode: FeatureMode) {
        switch engineMode {
        case .aid:
            countOfUsingAid += 1
        case .recognize:
            countOfUsingRecognize += 1
        case .translate:
            countOfTranslate += 1
        }
    }
    
    // MARK: - Private methods
    @objc private func audioRouteChanged(notification: NSNotification) {
        guard let audioRouteChangeReason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt else {
            return
        }

        switch audioRouteChangeReason {
        case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
            guard audioEngine?.avEngine.isRunning == false else {
                return
            }
            try? audioEngine?.start()
        default:
            break
        }
    }
}

final class EqualizerMixer {

    private(set) var mapBand: [EqualizerBands: EqualizerFilter] = [:]
    private(set) var outputNode: Mixer!

    init(input: Node) {
        var previous = input
        EqualizerBands.allCases.forEach { band in
            let eqBand = EqualizerFilter(previous, centerFrequency: AUValue(band.hz), bandwidth: AUValue(band.bandwidth))
            eqBand.gain = AUValue(band.value)
            mapBand[band] = eqBand
            previous = eqBand
        }
        let nodes = mapBand.values.compactMap { $0 }
        outputNode = Mixer(nodes)
    }
    
    // MARK: - Methods
    func start() {
        mapBand.values.forEach { $0.start() }
    }
    
    func stop() {
        mapBand.values.forEach { $0.bypass() }
    }
    
    func setNew(_ value: Double, for band: EqualizerBands) {
        guard let eqBand = mapBand[band] else {
            return
        }
        eqBand.$gain.ramp(to: AUValue(value), duration: 0.02)
        band.setNew(value)
    }

    func valueFor(band: EqualizerBands) -> Double {
        return Double(mapBand[band]?.gain ?? 0)
    }

    func reset() {
        EqualizerBands.allCases.forEach { band in
            setNew(EqualizerBands.defaultValue, for: band)
        }
    }
}
