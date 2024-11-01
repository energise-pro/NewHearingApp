import Foundation

enum MicrophoneType: Int, CaseIterable {
    case bottom
    case front
    case back
    case headphones
    
    static var defaultMicrophone = MicrophoneType.bottom
    
    static var selectedMicrophone: MicrophoneType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "SelectedMicrophone")
        }
        get {
            let intValue = UserDefaults.standard.value(forKey: "SelectedMicrophone") as? Int ?? defaultMicrophone.rawValue
            let savedMicrophoneType = MicrophoneType(rawValue: intValue)!
            return savedMicrophoneType == .headphones && !AudioKitService.shared.connectedHeadphones ? defaultMicrophone : savedMicrophoneType
        }
    }
    
    var title: String {
        switch self {
        case .bottom:
            return "Bottom".localized()
        case .front:
            return "Front".localized()
        case .back:
            return "Rear".localized()
        case .headphones:
            return "Headphones".localized()
        }
    }
}

enum TemplatesType: Int, CaseIterable {
    case smallRoom
    case mediumRoom
    case largeRoom
    case mediumHall
    case largeHall
    case plate
    case mediumChamber
    case largeChamber
    case cathedral
    case largeRoom2
    case mediumHall2
    case mediumHall3
    case largeHall2
    
    static var defaultTemplate = TemplatesType.largeRoom
    
    static var selectedTemplate: TemplatesType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "Reverb.Preset")
        }
        get {
            let intValue = UserDefaults.standard.value(forKey: "Reverb.Preset") as? Int ?? defaultTemplate.rawValue
            return TemplatesType(rawValue: intValue)!
        }
    }

    var title: String {
        switch self {
            case .smallRoom:        return "smallRoom".localized()
            case .mediumRoom:       return "mediumRoom".localized()
            case .largeRoom:        return "largeRoom".localized()
            case .mediumHall:       return "mediumHall".localized()
            case .largeHall:        return "largeHall".localized()
            case .plate:            return "plate".localized()
            case .mediumChamber:    return "mediumChamber".localized()
            case .largeChamber:     return "largeChamber".localized()
            case .cathedral:        return "cathedral".localized()
            case .largeRoom2:       return "largeRoom2".localized()
            case .mediumHall2:      return "mediumHall2".localized()
            case .mediumHall3:      return "mediumHall3".localized()
            case .largeHall2:       return "largeHall2".localized()
        }
    }
}

enum TemplatesParameter: String, CaseIterable {
    case dryWet
    
    var title: String {
        return "effect volume".localized()
    }
    var defaultValue: Double {
        return 0.2
    }
    var minValue: Double {
        return 0
    }
    var maxValue: Double {
        return 1
    }
    
    var value: Double {
        return UserDefaults.standard.value(forKey: "Reverb\(self.rawValue)") as? Double ?? defaultValue
    }
    
    func setNew(_ value: Double) {
        UserDefaults.standard.set(value, forKey: "Reverb\(self.rawValue)")
    }
}

enum CompressorParameter: String, CaseIterable {
    case threshold, attackDuration, releaseDuration, masterGain
    
    var title: String {
        switch self {
        case .threshold: return "threshold".localized()
        case .attackDuration: return "attack duration".localized()
        case .releaseDuration: return "release duration".localized()
        case .masterGain: return "effect volume".localized()
        }
    }
    
    var defaultValue: Double {
        switch self {
        case .threshold: return -30.0
        case .attackDuration: return 0.1052
        case .releaseDuration: return 1.532
        case .masterGain: return 12
        }
    }
    
    var minValue: Double {
        switch self {
        case .threshold: return -30
        case .attackDuration: return 0.0001
        case .releaseDuration: return 0.01
        case .masterGain: return 0
        }
    }
    
    var maxValue: Double {
        switch self {
        case .threshold: return 0
        case .attackDuration: return 0.2
        case .releaseDuration: return 3
        case .masterGain: return 12
        }
    }
    
    var value: Double {
        return UserDefaults.standard.value(forKey: "Compressor\(self.rawValue)") as? Double ?? defaultValue
    }
    
    func setNew(_ value: Double) {
        UserDefaults.standard.set(value, forKey: "Compressor\(self.rawValue)")
    }
}

enum PitchShifterParameter: String, CaseIterable {
    case shift, windowSize, crossFade
    
    var title: String {
        switch self {
        case .shift: return "Base shift".localized()
        case .windowSize: return "Range".localized()
        case .crossFade: return "Speed".localized()
        }
    }

    var defaultValue: Double {
        switch self {
        case .shift: return 0.0
        case .windowSize: return 1024.0
        case .crossFade: return 512.0
        }
    }

    var minValue: Double {
        switch self {
        case .shift: return -10.0
        case .windowSize: return 0.0
        case .crossFade: return 0.0
        }
    }

    var maxValue: Double {
        switch self {
        case .shift: return 10.0
        case .windowSize: return 5000.0
        case .crossFade: return 5000.0
        }
    }
    
    var value: Double {
        return UserDefaults.standard.value(forKey: "PitchShifter\(self.rawValue)") as? Double ?? defaultValue
    }
    
    func setNew(_ value: Double) {
        UserDefaults.standard.set(value, forKey: "PitchShifter\(self.rawValue)")
    }
}

enum PeakLimiterParameter: String, CaseIterable {
    case attackDuration, decayDuration, preGain

    var title: String {
        switch self {
        case .attackDuration: return "attack duration".localized()
        case .decayDuration: return "decay duration".localized()
        case .preGain: return "effect volume".localized()
        }
    }

    var defaultValue: Double {
        switch self {
        case .attackDuration: return  0.001
        case .decayDuration: return 0.001
        case .preGain: return 0
        }
    }

    var minValue: Double {
        switch self {
        case .attackDuration: return 0.001
        case .decayDuration: return 0.001
        case .preGain: return 0
        }
    }

    var maxValue: Double {
        switch self {
        case .attackDuration: return 0.03
        case .decayDuration: return 0.06
        case .preGain: return 12
        }
    }
    
    var value: Double {
        return UserDefaults.standard.value(forKey: "Limiter\(self.rawValue)") as? Double ?? defaultValue
    }
    
    func setNew(_ value: Double) {
        UserDefaults.standard.set(value, forKey: "Limiter\(self.rawValue)")
    }
}

enum EqualizerBands: String, CaseIterable {
    static let minValue: Double = -100
    static let maxValue: Double = 100
    static let defaultValue: Double = EqualizerBands.maxValue + EqualizerBands.minValue
    //low
    case Hz60, Hz90, Hz135, Hz250
    //mid
    case Hz500, Hz680, Hz1k, Hz2k
    //Hi
    case Hz3k, Hz4k, Hz5k, Hz6k
    
    var hzTitle: String {
        return "\(self.hz) Hz"
    }
    
    var hz: Double {
        switch self {
        case .Hz60: return 30
        case .Hz90: return 90
        case .Hz135: return 135
        case .Hz250: return 250
        case .Hz500: return 500
        case .Hz680: return 700
        case .Hz1k: return 1000
        case .Hz2k: return 2000
        case .Hz3k: return 3000
        case .Hz4k: return 4000
        case .Hz5k: return 5000
        case .Hz6k: return 6000
        }
    }

    var bandwidth: Double {
        switch self {
        case .Hz60,.Hz90,.Hz135,.Hz250,.Hz500,.Hz680: return 100
        case .Hz1k,.Hz2k,.Hz3k, .Hz4k, .Hz5k, .Hz6k: return 1000
        }
    }

    var value: Double {
        return UserDefaults.standard.value(forKey: rawValue) as? Double ?? EqualizerBands.defaultValue
    }

    func setNew(_ value: Double) {
        UserDefaults.standard.setValue(value, forKey: rawValue)
    }
}
