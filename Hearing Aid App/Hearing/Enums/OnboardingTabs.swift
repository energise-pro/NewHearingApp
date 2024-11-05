import UIKit

enum TOnboardHvTabs: Int, CaseIterable {
    
    case noiseSuppression
    case speachRecognition
    case volumeBoost
    case speechTranslate
   
    var title: String {
        switch self {
        case .volumeBoost:
            return "Super volume boost".localized()
        case .noiseSuppression:
            return "Regulated noise suppression".localized()
        case .speachRecognition:
            return "Live transcribe".localized()
        case .speechTranslate:
            return "Translation Services 60+ languages".localized()
        }
    }
    
    var description: String {
        switch self {
        case .volumeBoost:
            return "Full acoustic amplification up to 30 dB with a wired headset".localized()
        case .noiseSuppression:
            return "Elimination of background noises and increase of speech intelligibility".localized()
        case .speachRecognition:
            return "Makes everyday conversations and surrounding sounds more accessible".localized()
        case .speechTranslate:
            return "Continuously translate speech in near real-time. Ability to rotate the screen".localized()
        }
    }
    
    var icon: UIImage {
        switch self {
        case .volumeBoost:
            return UIImage(named: "icMan")!
        case .noiseSuppression:
            return UIImage(named: "icManAndWoman")!
        case .speachRecognition:
            return UIImage(named: "icTranscribeHand")!
        case .speechTranslate:
            return UIImage(named: "icTranslateHand")!
        }
    }
    
    var afterRingtonePath: String {
        switch self {
        case .volumeBoost:
            return "guitarAfter"
        case .noiseSuppression:
            return "dialogAfter"
        case .speachRecognition, .speechTranslate:
            return ""
        }
    }
    
    var beforeRingtonePath: String {
        switch self {
        case .volumeBoost:
            return "guitarBefore"
        case .noiseSuppression:
            return "dialogBefore"
        case .speachRecognition, .speechTranslate:
            return ""
        }
    }
}
