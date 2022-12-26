//
//  ViewFactory.swift
//  HearingAidApp
//
//  Created by Lidia Michalak on 15.12.2022.
//

import UIKit

protocol ViewFactoryProtocol {
    
    func makeOnboardingView() -> OnboardingView
    func makePaywallView() -> PaywallView
    func makePermissionsViwe() -> PermissionsView
    func makeHeadphonesConnectionView() -> HeadphonesConnectionView
    func makeHearingAidView() -> HearingAidView
    func makeSpeechRecognitionView() -> SpeechRecognitionView
    func makeSettingsView() -> SettingsView
    func makeWebView() -> WebView
    func makeLanguagesListView() -> LanguagesListView
    func makeTypeView() -> TypeView
}

final class ViewFactory: ViewFactoryProtocol {
    
    // MARK: - Public Methods
    func makeOnboardingView() -> OnboardingView {
        return OnboardingViewController()
    }
    
    func makePaywallView() -> PaywallView {
        return PaywallViewController()
    }
    
    func makePermissionsViwe() -> PermissionsView {
        return PermissionsViewController()
    }
    
    func makeHeadphonesConnectionView() -> HeadphonesConnectionView {
        return HeadphonesConnectionViewController()
    }
    
    func makeHearingAidView() -> HearingAidView {
        let viewController = HearingAidViewController()
        viewController.tabBarItem = UITabBarItem(title: "Hearing Aid".localized,
                                                 image: UIImage(named: "hearing-aid-tab-icon"),
                                                 selectedImage: UIImage(named: "hearing-aid-tab-icon"))
        return viewController
    }
    
    func makeSpeechRecognitionView() -> SpeechRecognitionView {
        let viewController = SpeechRecognitionViewController()
        viewController.tabBarItem = UITabBarItem(title: "Speech Recognition".localized,
                                                 image: UIImage(named: "speech-recognition-tab-icon"),
                                                 selectedImage: UIImage(named: "speech-recognition-tab-icon"))
        return viewController
    }
    
    func makeTypeView() -> TypeView {
        let viewController = TypeViewController()
        viewController.tabBarItem = UITabBarItem(title: "Type".localized,
                                                 image: UIImage(named: "type-tab-icon"),
                                                 selectedImage: UIImage(named: "type-tab-icon"))
        return viewController
    }
    
    func makeSettingsView() -> SettingsView {
        let viewController = SettingsViewController()
        viewController.tabBarItem = UITabBarItem(title: "Settings".localized,
                                                 image: UIImage(named: "settings-tab-icon"),
                                                 selectedImage: UIImage(named: "settings-tab-icon"))
        return viewController
    }
    
    func makeWebView() -> WebView {
        return WebViewController()
    }
    
    func makeLanguagesListView() -> LanguagesListView {
        return LanguagesListViewController()
    }
}
