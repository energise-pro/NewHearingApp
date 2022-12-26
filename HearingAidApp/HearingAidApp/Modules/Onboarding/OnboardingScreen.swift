//
//  OnboardingScreen.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 09.12.2022.
//

import UIKit

enum OnboardingScreen {
    
    // MARK: - Cases
    case regulatedNoiseSuppression
    case superVolumeBoost
    case speechRecognition
    case aboutFreeTrial
    
    // MARK: - Public Properties
    var title: String {
        switch self {
        case .regulatedNoiseSuppression:
            return "Regulated noise suppression".localized
        case .superVolumeBoost:
            return "Super volume boost".localized
        case .speechRecognition:
            return "Speech recognition".localized
        case .aboutFreeTrial:
            return "How your Free trial works".localized
        }
    }
    
    var subtitle: String {
        switch self {
        case .regulatedNoiseSuppression:
            return "Elimination of backgroud noises and increase of speech intelligibility".localized
        case .superVolumeBoost:
            return "Full acoustic amplification up to 30 dB with a wired headset".localized
        case .speechRecognition:
            return "Automatic conversion of the recorded speech into text.".localized
        case .aboutFreeTrial:
            return "3 days free trial, after %@/month".localized
        }
    }
    
    var image: UIImage? {
        switch self {
        case .regulatedNoiseSuppression:
            return UIImage(named: "girl-near-sea")
        case .superVolumeBoost:
            return UIImage(named: "two-girls-with-airpods")
        case .speechRecognition:
            return UIImage(named: "kitchen")
        case .aboutFreeTrial:
            return nil
        }
    }
    
    var index: Int {
        switch self {
        case .regulatedNoiseSuppression:
            return 0
        case .superVolumeBoost:
            return 1
        case .speechRecognition:
            return 2
        case .aboutFreeTrial:
            return 3
        }
    }
}
