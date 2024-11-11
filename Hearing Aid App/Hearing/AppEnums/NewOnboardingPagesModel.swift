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
   
    var title: String {
        switch self {
        case .boostVolume:
            return "Boost Volume".localized()
        case .customizeSound:
            return "Customize Sound".localized()
        case .trustedProfessionals:
            return "Trusted by Professionals".localized()
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
        }
    }
    
    var mainImage: UIImage {
        switch self {
        case .boostVolume:
            return UIImage(named: "firstPageOBImage")!
        case .customizeSound:
            return UIImage(named: "secondPageOBImage")!
        case .trustedProfessionals:
            return UIImage(named: "thirdPageOBImage")!
        }
    }
    
    var bottomViewImage: UIImage? {
        switch self {
        case .boostVolume, .customizeSound:
            return nil
        case .trustedProfessionals:
            return UIImage(named: "icTranscribeHand")!
        }
    }
}
