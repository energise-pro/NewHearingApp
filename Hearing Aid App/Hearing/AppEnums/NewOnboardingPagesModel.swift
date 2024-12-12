//
//  NewOnboardingPagesModel.swift
//  Hearing Aid App
//
//  Created by Evgeniy Zelinskiy on 11.11.2024.
//

import UIKit

enum NewOnboardingPagesModel: Int, CaseIterable {
    
    case boostVolume
    case customizeSound
    case trustedProfessionals
    case transcribe
    case translate
   
    var title: String {
        switch self {
        case .boostVolume:
            return "Boost Volume".localized()
        case .customizeSound:
            return "Customize Sound".localized()
        case .trustedProfessionals:
            return "Trusted by Professionals".localized()
        case .transcribe:
            return "Transcribe in Real Time".localized()
        case .translate:
            return "Translate in Real Time".localized()
        }
    }
    
    var description: String {
        switch self {
        case .boostVolume:
            return "Hear every detail with powerful sound boost.".localized()
        case .customizeSound:
            return "Eliminate noise, select presets, fine-tune sound for a fully personalized experience.".localized()
        case .trustedProfessionals:
            return "Recommended by doctors and trusted by millions of users worldwide.".localized()
        case .transcribe:
            return "Transcribe speech into easy-to-read text in real time with superior accuracy.".localized()
        case .translate:
            return "Translate speech in real time, supporting 60+ languages offline.".localized()
        }
    }
    
    var mainImage: UIImage {
        switch self {
        case .boostVolume:
            return UIImage(named: "page1OBImage")!
        case .customizeSound:
            return UIImage(named: "page2OBImage")!
        case .trustedProfessionals:
            return UIImage(named: "page3OBImage")!
        case .transcribe:
            return UIImage(named: "page4OBImage")!
        case .translate:
            return UIImage(named: "page5OBImage")!
        }
    }
    
    var bottomViewImage: UIImage? {
        switch self {
        case .boostVolume, .customizeSound, .transcribe, .translate:
            return nil
        case .trustedProfessionals:
            return UIImage(named: "icTranscribeHand")!
        }
    }
}
