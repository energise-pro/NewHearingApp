//
//  PermissionType.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 18.12.2022.
//

import UIKit

enum PermissionType {
    
    // MARK: - Cases
    case microphoneUsage
    case speechRecognition
    
    // MARK: - Public Properties
    var title: String {
        switch self {
        case .microphoneUsage:
            return "Please Allow Microphone Usage".localized
        case .speechRecognition:
            return "Allow Speech recognition function".localized
        }
    }
    
    var subtitle: String {
        switch self {
        case .microphoneUsage:
            return "Dear User, for correctly work with our app, we need your microphone usage permission".localized
        case .speechRecognition:
            return "Dear User, for use Speech recognition function, you need to allow permission".localized
        }
    }
    
    var image: UIImage? {
        switch self {
        case .microphoneUsage:
            return UIImage(named: "microphone-access")
        case .speechRecognition:
            return UIImage(named: "speech-recognition-access")
        }
    }
}
